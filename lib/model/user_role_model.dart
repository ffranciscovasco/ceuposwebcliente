class UserRoleModel {
  late String email, userTitle, databaseId;
  late bool salePermission,
      partiesPermission,
      purchasePermission,
      productPermission,
      profileEditPermission,
      addExpensePermission,
      lossProfitPermission,
      dueListPermission,
      stockPermission,
      reportsPermission,
      salesListPermission,
      purchaseListPermission;

  String? userKey;

  UserRoleModel({
    required this.email,
    required this.userTitle,
    required this.databaseId,
    required this.salePermission,
    required this.partiesPermission,
    required this.purchasePermission,
    required this.productPermission,
    required this.profileEditPermission,
    required this.addExpensePermission,
    required this.lossProfitPermission,
    required this.dueListPermission,
    required this.stockPermission,
    required this.reportsPermission,
    required this.salesListPermission,
    required this.purchaseListPermission,
    this.userKey,
  });

  UserRoleModel.fromJson(Map<dynamic, dynamic> json)
      : email = json['email'] ?? '',
        userTitle = json['userTitle'] ?? '',
        databaseId = json['databaseId'] ?? '',
        salePermission = json['salePermission'] ?? false,
        partiesPermission = json['partiesPermission'] ?? false,
        purchasePermission = json['purchasePermission'] ?? false,
        productPermission = json['productPermission'] ?? false,
        profileEditPermission = json['profileEditPermission'] ?? false,
        addExpensePermission = json['addExpensePermission'] ?? false,
        lossProfitPermission = json['lossProfitPermission'] ?? false,
        dueListPermission = json['dueListPermission'] ?? false,
        stockPermission = json['stockPermission'] ?? false,
        reportsPermission = json['reportsPermission'] ?? false,
        salesListPermission = json['salesListPermission'] ?? false,
        purchaseListPermission = json['purchaseListPermission'] ?? false;

  Map<dynamic, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'userTitle': userTitle,
        'databaseId': databaseId,
        'salePermission': salePermission,
        'partiesPermission': partiesPermission,
        'purchasePermission': purchasePermission,
        'productPermission': productPermission,
        'profileEditPermission': profileEditPermission,
        'addExpensePermission': addExpensePermission,
        'lossProfitPermission': lossProfitPermission,
        'dueListPermission': dueListPermission,
        'stockPermission': stockPermission,
        'reportsPermission': reportsPermission,
        'salesListPermission': salesListPermission,
        'purchaseListPermission': purchaseListPermission,
      };
}
