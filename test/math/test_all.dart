import 'package:test/test.dart';

import 'ast_test.dart' as ast_test;
import 'proof_test.dart' as proof_test;
import 'rules_test.dart' as rules_test;

main() {
  group('ast_test', ast_test.main);
  group('proof_test', proof_test.main);
  group('rules_test', rules_test.main);
}
