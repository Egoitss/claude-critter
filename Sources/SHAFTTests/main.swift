// SHAFT test runner (CLT-compatible). Each task appends a run<Suite>() call
// here, then xctReport() sets the process exit code.
import SHAFTTestKit

runSmokeTests()
runModelTests()
runUsageTests()
runBalanceTests()
try runKeychainTests()
try runTmuxTests()
runTmuxSwitchTests()
runTmuxTargetTests()
runSelfTargetTests()
runSettingsTests()
try await runUsageClientTests()
runCritterTests()
runPixelFontTests()
runGaugeTests()
runGaugeMetricTests()
xctReport()
