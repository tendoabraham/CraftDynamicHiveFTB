// ignore_for_file: prefer_typing_uninitialized_variables

part of craft_dynamic;

class ModuleRepository {
  Future<Box<ModuleItem>> openBox() async {
    if (Hive.isBoxOpen("modules")) {
      return Hive.box<ModuleItem>("modules");
    } else {
      return await Hive.openBox<ModuleItem>("modules");
    }
  }

  insertModuleItems(List<ModuleItem> moduleItems) async {
    var box = await openBox();
    try {
      box.addAll(moduleItems);
    } catch (e) {
      AppLogger.appLogE(tag: "module insertion", message: e.toString());
    }
  }

  Future<ModuleItem?> getModuleById(String moduleID) async {
    ModuleItem? module;
    try {
      var box = await openBox();
      module = box.values.firstWhereOrNull((item) => item.moduleId == moduleID);
      return module;
    } catch (e) {
      AppLogger.appLogE(tag: "get module by id", message: e);
    }
    return module;
  }

  Future<List<ModuleItem>?> getModulesById(String moduleID) async {
    List<ModuleItem>? modules;
    try {
      var box = await openBox();

      var loginHiddenModulesRepo = ModuleToHideRepository();
      List<ModuleToHide>? modulesToHide =
          await loginHiddenModulesRepo.getAllModulesToHide();
      var modules = box.values
          .where(
              (item) => item.parentModule == moduleID && item.isHidden == false)
          .toList();

      modulesToHide?.forEach((module) {
        modules.removeWhere((item) => item.moduleId == module.moduleId);
      });
      modules
          .sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
      return modules;
    } catch (e) {
      AppLogger.appLogE(tag: "get modules by id", message: e);
    }

    return modules;
  }

  Future<List<ModuleItem>?> searchModuleItem(String moduleName) async {
    var box = await openBox();
    return box.values
        .where(
            (item) => item.moduleName == moduleName && item.isHidden == false)
        .toList();
  }

  Future<List<ModuleItem>?> getTabModules() async {
    var box = await openBox();
    var modules = box.values
        .where((item) =>
            item.parentModule == ModuleId.MAIN.name &&
            item.isMainMenu == true &&
            item.isHidden == false)
        .toList();

    modules
        .sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));

    return modules;
  }

  closeBox() async {
    var box = await openBox();
    await box.deleteFromDisk();
  }
}

class FormsRepository {
  Future<Box<FormItem>> openBox() async {
    if (Hive.isBoxOpen("forms")) {
      return Hive.box<FormItem>("forms");
    } else {
      return await Hive.openBox<FormItem>("forms");
    }
  }

  insertFormItems(List<FormItem> formItems) async {
    var box = await openBox();
    await box.clear();
    try {
      for (var formItem in formItems) {
        box.add(formItem);
      }
    } catch (e) {
      AppLogger.appLogE(tag: "insert form item", message: e.toString());
    }
  }

  Future<List<FormItem>?> getFormsByModuleId(String moduleID) async {
    var box = await openBox();
    var forms = box.values
        .where((item) => item.moduleId == moduleID && item.hidden == false)
        .toList();
    forms.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
    return forms;
  }

  Future<List<FormItem>?>? getFormsByModuleIdAndFormSequence(
      String moduleID, int formSequence) async {
    var box = await openBox();
    return box.values
        .where((item) =>
            item.moduleId == moduleID &&
            item.formSequence == formSequence &&
            item.hidden == false)
        .toList();
  }

  Future<List<FormItem>?>? getFormsByModuleIdAndControlID(
      String moduleID, String controlID) async {
    var box = await openBox();
    return box.values
        .where((item) =>
            item.moduleId == moduleID &&
            item.controlId == controlID &&
            item.hidden == false)
        .toList();
  }
}

class ActionControlRepository {
  Future<Box<ActionItem>> openBox() async {
    if (Hive.isBoxOpen("actions")) {
      return Hive.box<ActionItem>("actions");
    } else {
      return await Hive.openBox<ActionItem>("actions");
    }
  }

  insertActionControls(List<ActionItem> actionItems) async {
    var box = await openBox();
    await box.clear();
    for (var actionItem in actionItems) {
      box.add(actionItem);
    }
  }

  Future<ActionItem?> getActionControlByModuleIdAndControlId(
      String moduleID, controlID) async {
    var box = await openBox();
    return box.values.firstWhereOrNull(
        (item) => item.moduleID == moduleID && item.controlID == controlID);
  }
}

class UserCodeRepository {
  Future<Box<UserCode>> openBox() async {
    if (Hive.isBoxOpen("usercodes")) {
      return Hive.box<UserCode>("usercodes");
    } else {
      return await Hive.openBox<UserCode>("usercodes");
    }
  }

  insertUserCodes(List<UserCode> userCodes) async {
    var box = await openBox();
    await box.clear();
    for (var usercode in userCodes) {
      box.add(usercode);
    }
  }

  Future<List<UserCode>> getUserCodesById(String? id) async {
    var box = await openBox();
    return box.values.where((item) => item.id == id).toList();
  }
}

class OnlineAccountProductRepository {
  Future<Box<OnlineAccountProduct>> openBox() async {
    if (Hive.isBoxOpen("onlineAccountProducts")) {
      return Hive.box<OnlineAccountProduct>("onlineAccountProducts");
    } else {
      return await Hive.openBox<OnlineAccountProduct>("onlineAccountProducts");
    }
  }

  insertOnlineAccountProducts(
      List<OnlineAccountProduct> onlineAccountProducts) async {
    var box = await openBox();
    await box.clear();
    for (var product in onlineAccountProducts) {
      box.add(product);
    }
  }

  Future<List<OnlineAccountProduct>> getAllOnlineAccountProducts() async {
    var box = await openBox();
    return box.values.toList();
  }
}

class BankBranchRepository {
  Future<Box<BankBranch>> openBox() async {
    if (Hive.isBoxOpen("bankbranches")) {
      return Hive.box<BankBranch>("bankbranches");
    } else {
      return await Hive.openBox<BankBranch>("bankbranches");
    }
  }

  insertBankBranches(List<BankBranch> bankBranches) async {
    var box = await openBox();
    await box.clear();
    for (var branch in bankBranches) {
      box.add(branch);
    }
  }

  Future<List<BankBranch>> getAllBankBranches() async {
    var bankBranchBox = await openBox();
    return bankBranchBox.values.toList();
  }
}

class ImageDataRepository {
  Future<Box<ImageData>> openBox() async {
    if (Hive.isBoxOpen("imagedata")) {
      return Hive.box<ImageData>("imagedata");
    } else {
      return await Hive.openBox<ImageData>("imagedata");
    }
  }

  insertImages(List<ImageData> images) async {
    var box = await openBox();
    await box.clear();
    box.addAll(images);
  }

  Future<List<ImageData>> getAllImages(String imageType) async {
    var box = await openBox();
    return box.values.toList();
  }
}

class BankAccountRepository {
  Future<Box<BankAccount>> openBox() async {
    if (Hive.isBoxOpen("bankaccount")) {
      return Hive.box<BankAccount>("bankaccount");
    } else {
      return await Hive.openBox<BankAccount>("bankaccount");
    }
  }

  insertBankAccounts(List<BankAccount> bankAccounts) async {
    try {
      bankAccounts.sort((a, b) =>
          (b.defaultAccount ? 1 : 0).compareTo(a.defaultAccount ? 1 : 0));

      var box = await openBox();
      await box.clear();
      box.addAll(bankAccounts);
    } catch (e) {
      AppLogger.appLogE(tag: "add bank account", message: e.toString());
    }
  }

  Future<List<BankAccount>?> getAllBankAccounts() async {
    var box = await openBox();
    var accounts = box.values.toList();
    return accounts;
  }

  Future<BankAccount?> getBankAccount(String accountID) async {
    var box = await openBox();
    return box.values
        .firstWhereOrNull((account) => account.bankAccountId == accountID);
  }
}

class FrequentAccessedModuleRepository {
  Future<Box<FrequentAccessedModule>> openBox() async {
    if (Hive.isBoxOpen("frequentmodules")) {
      return Hive.box<FrequentAccessedModule>("frequentmodules");
    } else {
      return await Hive.openBox<FrequentAccessedModule>("frequentmodules");
    }
  }

  insertFrequentModules(
      List<FrequentAccessedModule> frequentAccessedModules) async {
    var box = await openBox();
    await box.clear();
    box.addAll(frequentAccessedModules);
  }

  Future<List<FrequentAccessedModule>> getAllFrequentModules() async {
    var box = await openBox();
    return box.values.toList();
  }
}

class BeneficiaryRepository {
  Future<Box<Beneficiary>> openBox() async {
    if (Hive.isBoxOpen("beneficiaries")) {
      return Hive.box<Beneficiary>("beneficiaries");
    } else {
      return await Hive.openBox<Beneficiary>("beneficiaries");
    }
  }

  insertBeneficiaries(List<Beneficiary> beneficiaries) async {
    var box = await openBox();
    await box.clear();
    for (var beneficiary in beneficiaries) {
      box.put(beneficiary.rowId, beneficiary);
    }
  }

  Future<List<Beneficiary>>? getAllBeneficiaries() async {
    var box = await openBox();
    return box.values.toList();
  }

  Future<List<Beneficiary>>? getBeneficiariesByMerchantID(
      String merchantID) async {
    var box = await openBox();
    return box.values.where((item) => item.merchantID == merchantID).toList();
  }

  deleteBeneficiary(int rowId) async {
    var box = await openBox();
    box.delete(rowId);
  }
}

class ModuleToHideRepository {
  Future<Box<ModuleToHide>> openBox() async {
    if (Hive.isBoxOpen("modulesToHide")) {
      return Hive.box<ModuleToHide>("modulesToHide");
    } else {
      return await Hive.openBox<ModuleToHide>("modulesToHide");
    }
  }

  insertModulesToHide(List<ModuleToHide> modules) async {
    var box = await openBox();
    await box.clear();
    for (var moduleToHide in modules) {
      box.put(moduleToHide.moduleId, moduleToHide);
    }
  }

  Future<List<ModuleToHide>?>? getAllModulesToHide() async {
    var box = await openBox();
    return box.values.toList();
  }
}

class ModuleToDisableRepository {
  Future<Box<ModuleToDisable>> openBox() async {
    if (Hive.isBoxOpen("modulesToDisable")) {
      return Hive.box<ModuleToDisable>("modulesToDisable");
    } else {
      return await Hive.openBox<ModuleToDisable>("modulesToDisable");
    }
  }

  insertModulesToDisable(List<ModuleToDisable> modules) async {
    var box = await openBox();
    await box.clear();
    for (var module in modules) {
      box.put(module.moduleID, module);
    }
  }

  Future<List<ModuleToDisable>>? getAllModulesToDisable() async {
    var box = await openBox();
    return box.values.toList();
  }
}

class AtmLocationRepository {
  Future<Box<AtmLocation>> openBox() async {
    if (Hive.isBoxOpen("atmLocations")) {
      return Hive.box<AtmLocation>("atmLocations");
    } else {
      return await Hive.openBox<AtmLocation>("atmLocations");
    }
  }

  insertAtmLocations(List<AtmLocation> atmLocations) async {
    var box = await openBox();
    await box.clear();
    box.addAll(atmLocations);
  }

  Future<List<AtmLocation>> getAllAtmLocations() async {
    var box = await openBox();
    return box.values.toList();
  }
}

class BranchLocationRepository {
  Future<Box<BranchLocation>> openBox() async {
    if (Hive.isBoxOpen("branchLocations")) {
      return Hive.box<BranchLocation>("branchLocations");
    } else {
      return await Hive.openBox<BranchLocation>("branchLocations");
    }
  }

  insertBranchLocations(List<BranchLocation> branchLocations) async {
    var box = await openBox();
    await box.clear();
    try {
      box.addAll(branchLocations);
    } catch (e) {
      AppLogger.appLogD(tag: "error inserting branch", message: e);
    }
  }

  Future<List<BranchLocation>> getAllBranchLocations() async {
    var box = await openBox();
    return box.values.toList();
  }
}

class PendingTrxDisplayRepository {
  Future<Box<PendingTrxDisplay>> openBox() async {
    if (Hive.isBoxOpen("pendingTransactions")) {
      return Hive.box<PendingTrxDisplay>("pendingTransactions");
    } else {
      return await Hive.openBox<PendingTrxDisplay>("pendingTransactions");
    }
  }

  insertPendingTransactions(List<PendingTrxDisplay> transactions) async {
    var box = await openBox();
    await box.clear();
    for (var item in transactions) {
      box.put(item.no, item);
    }
  }

  Future<List<PendingTrxDisplay>> getAllPendingTransactions() async {
    var box = await openBox();
    return box.values.toList();
  }
}

class FaqRepository {
  Future<Box<Faq>> openBox() async {
    if (Hive.isBoxOpen("faqs")) {
      return Hive.box<Faq>("faqs");
    } else {
      return await Hive.openBox<Faq>("faqs");
    }
  }

  insertFaqs(List<Faq> faqs) async {
    var box = await openBox();
    await box.clear();
    box.addAll(faqs);
  }

  Future<List<Faq>> getAllFaqs() async {
    var box = await openBox();
    return box.values.toList();
  }
}
