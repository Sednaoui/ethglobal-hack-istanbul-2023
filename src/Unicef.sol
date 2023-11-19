// SPDX-License-Identifier: MIT
// Author : Candide Team
// Modified OpenZeppelin Contracts (token/ERC20/extensions/ERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20, IERC20Metadata, ERC20} from "./ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract UnicefVault is ERC20 {
    using Math for uint256;

    IERC20 private immutable _asset;
    uint8 private immutable _underlyingDecimals;
    address public immutable _owner;

    address internal constant SENTINEL_REDEEMERS = address(0x1);

    mapping (address => uint256) public maxDailyRedeemAmount;
    mapping (address => uint256) public totalAmountRedeemedLastDay;
    mapping (address => uint256) public lastRedeem;

    struct Distribution {
        address receiver;
        uint256 amount;
    }

    event Deposit(address indexed sender, address indexed owner, uint256 amount);
    event MaxRedeemChanged(address indexed redeemer, uint256 amount);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 amount
    );

    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */
    error ExceededMaxDeposit(address receiver, uint256 amount, uint256 max);

    /**
     * @dev Attempted to mint more shares than the max amount for `receiver`.
     */
    error ExceededMaxMint(address receiver, uint256 amount, uint256 max);

    /**
     * @dev Attempted to withdraw more assets than the max amount for `receiver`.
     */
    error ExceededMaxWithdraw(address owner, uint256 amount, uint256 max);

    /**
     * @dev Attempted to distribute more assets than the available balance.
     */
    error ExceededMaxDistribute(uint256 amount, uint256 max);

    /**
     * @dev Attempted to redeem more shares than the max amount for `receiver`.
     */
    error ExceededMaxRedeem(address owner, uint256 amount, uint256 max);

    /**
     * @dev Set the underlying asset contract. This must be an ERC20-compatible contract (ERC20 or ERC777).
     */
    constructor(string memory name, string memory symbol, IERC20 asset_, address owner) 
    ERC20(name, symbol){
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
        _owner = owner;
    }

    /**
     * @dev Attempts to fetch the asset decimals. A return value of false indicates that the attempt failed in some way.
     */
    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool, uint8) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeCall(IERC20Metadata.decimals, ())
        );
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }
        return (false, 0);
    }

    function asset() public view virtual returns (address) {
        return address(_asset);
    }

    function totalAssets() public view virtual returns (uint256) {
        return _asset.balanceOf(address(this));
    }

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        if(owner == _owner){
            balanceOf(owner);
        }else{
            return 0;
        }
        return balanceOf(owner);
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        if(_checkIfBeenAday(lastRedeem[owner])){
            return maxDailyRedeemAmount[owner] - totalAmountRedeemedLastDay[owner];
        }else{
            return maxDailyRedeemAmount[owner];
        }
    }

    function deposit(uint256 amount) public virtual {
        uint256 maxAmount = maxDeposit(address(this));
        if (amount > maxAmount) {
            revert ExceededMaxDeposit(address(this), amount, maxAmount);
        }

        _deposit(_msgSender(), address(this), amount);
    }

    function distribute(address receiver, uint256 amount) public virtual {
        if(_msgSender() != _owner){
            revert NotTheOwner(_msgSender());
        }
        uint256 maxDistribution = balanceOf(address(this));
        if (amount > maxDistribution){
            revert ExceededMaxDistribute(amount, maxDistribution);
        }
        _distribute(receiver, amount);
    }

    function batchDistribute(Distribution[] calldata distributions) public virtual {
        if(_msgSender() != _owner){
            revert NotTheOwner(_msgSender());
        }
        uint256 maxDistribution = balanceOf(address(this));
        uint256 totalDistribution = 0;
        for (uint256 i = 0; i < distributions.length; i++) {
            Distribution memory distribution = distributions[i];
            totalDistribution = totalDistribution + distribution.amount;
        }
        if (totalDistribution > maxDistribution){
            revert ExceededMaxDistribute(totalDistribution, maxDistribution);
        }
        for (uint256 i = 0; i < distributions.length; i++) {
            Distribution memory distribution = distributions[i];
            _distribute(distribution.receiver, distribution.amount);
        }
    }

    function withdraw(uint256 amount, address receiver, address owner) public virtual {
        uint256 maxAmount = maxWithdraw(owner);
        if (amount > maxAmount) {
            revert ExceededMaxRedeem(owner, amount, maxAmount);
        }

        _withdraw(_msgSender(), receiver, owner, amount);
    }

    function redeem(uint256 amount, address receiver, address owner) public virtual {
        uint256 maxAmount = maxRedeem(owner);
        if (amount > maxAmount) {
            revert ExceededMaxWithdraw(owner, amount, maxAmount);
        }

        if(_checkIfBeenAday(lastRedeem[owner])){
            totalAmountRedeemedLastDay[owner] = amount;
        }
        else{
            totalAmountRedeemedLastDay[owner] += amount;
        }
        _withdraw(_msgSender(), receiver, owner, amount);
    }

    error NotTheOwner(address notTheOwner);
    
    function setMaxDailyRedeemAmount(address redeemer, uint256 maxAmount) public {
        if(_msgSender() != _owner){
            revert NotTheOwner(_msgSender());
        }
        maxDailyRedeemAmount[redeemer] = maxAmount;
        emit MaxRedeemChanged(redeemer, maxAmount);
    }


    function _checkIfBeenAday(uint256 eventTime) internal view returns (bool){
        uint256 timeTellLastEvent = block.timestamp - eventTime;

        uint secondsInADay = 86400;
        return timeTellLastEvent > secondsInADay;
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address caller, address receiver, uint256 amount) internal virtual {
        // If _asset is ERC777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeTransferFrom(_asset, caller, address(this), amount);
        _mint(receiver, amount);

        emit Deposit(caller, receiver, amount);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 amount
    ) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, amount);
        }

        // If _asset is ERC777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        _burn(owner, amount);
        SafeERC20.safeTransfer(_asset, receiver, amount);

        emit Withdraw(caller, receiver, owner, amount);
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) override internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        if (maxDailyRedeemAmount[to] == 0 && to != _owner){
            revert ERC20InvalidReceiver(address(to));
        }
        _update(from, to, value);
    }

    function _distribute(address receiver, uint256 amount) internal virtual {
        _update(address(this), receiver, amount);
    }
}
