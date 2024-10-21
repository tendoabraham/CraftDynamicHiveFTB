// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:provider/provider.dart';

class ModulesListWidget extends StatefulWidget {
  Orientation orientation;
  ModuleItem? moduleItem;
  FrequentAccessedModule? favouriteModule;

  ModulesListWidget({
    super.key,
    required this.orientation,
    required this.moduleItem,
    this.favouriteModule,
  });

  @override
  State<ModulesListWidget> createState() => _ModulesListWidgetState();
}

class _ModulesListWidgetState extends State<ModulesListWidget> {
  final _moduleRepository = ModuleRepository();

  Future<List<ModuleItem>?> getModules() async {
    List<ModuleItem>? modules = await _moduleRepository.getModulesById(
        widget.favouriteModule == null
            ? widget.moduleItem!.moduleId
            : widget.favouriteModule!.moduleID);

    return modules;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DynamicState>(builder: (context, state, child) {
      BlockSpacing? blockSpacing = widget.moduleItem?.blockSpacing;

      return WillPopScope(
          onWillPop: () async {
            Provider.of<PluginState>(context, listen: false)
                .setRequestState(false);
            return true;
          },
          child: Scaffold(
              body: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 35,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Card(
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        //set border radius more than 50% of height and width to make circle
                      ),
                      color: const Color.fromARGB(255, 0, 80, 170),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 15),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Image(
                                image:
                                    AssetImage("assets/images/back_arrow.png"),
                                width: 25,
                              ),
                            ),
                            Expanded(
                                child: Text(
                              widget.moduleItem?.moduleName ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Myriad Pro",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                            Container(width: 25),
                          ],
                        ),
                      )),
                ),
                Expanded(
                    child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  height: double.maxFinite,
                  color: const Color.fromARGB(255, 219, 220, 221),
                  child: FutureBuilder<List<ModuleItem>?>(
                      future: getModules(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<ModuleItem>?> snapshot) {
                        Widget child =
                            const Center(child: Text("Please wait..."));
                        if (snapshot.hasData) {
                          var modules = snapshot.data?.toList();
                          modules?.removeWhere(
                              (module) => module.isHidden == true);

                          if (modules != null) {
                            child = SizedBox(
                                height: double.infinity,
                                child: GridView.builder(
                                    // physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14, top: 8, bottom: 8),
                                    shrinkWrap: true,
                                    itemCount: modules.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                blockSpacing?.axisCount ?? 3,
                                            crossAxisSpacing: 1,
                                            mainAxisSpacing: 4,
                                            childAspectRatio: widget.moduleItem
                                                    ?.blockAspectRatio ??
                                                .9),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var module = modules[index];
                                      return ModuleItemWidget(
                                          moduleItem: module);
                                    }));
                          }
                        }
                        return child;
                      }),
                ))
              ],
            ),
          )));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
