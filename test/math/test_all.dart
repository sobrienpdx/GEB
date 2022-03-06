import 'package:test/test.dart';

import 'ast_test.dart' as ast_test;
import 'challenge_test.dart' as challenge_test;
import 'proof_test.dart' as proof_test;
import 'rules_test.dart' as rules_test;
import 'state_test.dart' as state_test;

main() {
  group('ast_test', ast_test.main);
  group('challenge_test', challenge_test.main);
  group('proof_test', proof_test.main);
  group('rules_test', rules_test.main);
  group('state_test', state_test.main);
}
