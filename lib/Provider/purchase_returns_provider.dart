import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salespro_admin/Repository/sales_return_repo.dart';
import 'package:salespro_admin/model/purchase_transation_model.dart';

import '../Repository/purchase_return_repo.dart';
import '../model/sale_transaction_model.dart';

PurchaseReturnRepo salesReturnRepo = PurchaseReturnRepo();
final purchaseReturnProvider = FutureProvider<List<PurchaseTransactionModel>>((ref) => salesReturnRepo.getAllTransition());
