import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:unicef_aid_distributor/config/network.dart';
import 'package:unicef_aid_distributor/services/metamask_manager/metamask_manager.dart';
import 'package:unicef_aid_distributor/ui/tabs/approved_redeemers_tab.dart';
import 'package:unicef_aid_distributor/ui/tabs/distribute_tab.dart';
import 'package:unicef_aid_distributor/ui/tabs/donation_tab.dart';
import 'package:unicef_aid_distributor/widgets/c_button.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  EthereumAddress? mmConnectedAccount;
  late MetamaskManager metamaskManager;
  bool connected = false;
  bool isOwner = false;

  void mmConnect() async {
    await metamaskManager.connect();
    var connectedAccounts = await metamaskManager.getConnectedAccounts();
    if (connectedAccounts.isNotEmpty){
      var owner = await Network.instance.unicefVault.owner();
      mmConnectedAccount = connectedAccounts.first;
      isOwner = owner.hex == mmConnectedAccount!.hex;
      setState(() {
        connected = true;
      });
    }
  }

  @override
  void initState() {
    metamaskManager = MetamaskManager.instance;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          padding: const EdgeInsets.only(top: 13, bottom: 13),
          child: Image.asset("assets/logo.png"),
        ),
        titleSpacing: 0,
        title: Text("AidDistribute", style: TextStyle(fontWeight: FontWeight.bold, color: Get.theme.colorScheme.primary),),
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        actions: [
          CButton(
            onPressed: !connected ? (){
              mmConnect();
            } : null,
            child: Text(!connected ? "CONNECT WALLET" : "${mmConnectedAccount!.hex.substring(0, 12)}...",),
          ),
          const SizedBox(width: 10,),
        ],
      ),
      body: !connected ? Stack(
        children: [
          Positioned(
            top: 35,
            right: 70,
            child: Row(
              children: [
                Text("Connect first", style: GoogleFonts.pacifico(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                )),
                RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    PhosphorIcons.arrowBendUpLeft(PhosphorIconsStyle.bold),
                    size: 40,
                  ),
                )
              ],
            ),
          ),
        ],
      ) : Center(
        child: Card(
          color: Get.theme.colorScheme.surface,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            width: Get.width * 0.5,
            height: Get.height * 0.5,
            child: DefaultTabController(
              length: isOwner ? 3 : 1,
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(25)
                    ),
                    child: ButtonsTabBar(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(25)
                      ),
                      unselectedDecoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelStyle: TextStyle(
                        color: Get.theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: isOwner ? [
                        const Tab(text: "DONATE"),
                        const Tab(text: "APPROVED VENDORS"),
                        const Tab(text: "DISTRIBUTE"),
                      ] : [const Tab(text: "DONATE")],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: TabBarView(
                      children: isOwner ? [
                        const DonationTab(),
                        const ApprovedRedeemersTab(),
                        const DistributeTab(),
                      ] : [const DonationTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
