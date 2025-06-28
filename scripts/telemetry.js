import { execSync } from 'child_process';
import { join } from 'path';

const projectRoot = join(import.meta.dirname, '..');
const scriptPath = join(projectRoot, 'scripts', 'telemetry_gcp.js');

try {
  console.log(`🚀 Running telemetry script for target: gcp.`);
  execSync(`node ${scriptPath}`, { stdio: 'inherit', cwd: projectRoot });
} catch (error) {
  console.error(`🛑 Failed to run telemetry script for target: gcp`);
  console.error(error);
  process.exit(1);
}
