import * as system from "system";

const entry = `${App.configDir}/src/index.ts`;
const inScss = `${App.configDir}/style/index.scss`;
const outfile = "/tmp/ags/main.js";
const outCss = "/tmp/ags/style.css";

Utils.monitorFile("./src", () => {
    console.log("Rebuilding...");
    Utils.subprocess("ags")?.disconnect(0);
    system.exit(0);
});

Utils.monitorFile(inScss, async () => {
    console.log(["bun", "run", "--cwd", App.configDir, "sass", inScss, outCss].join(" "));
    await Utils.execAsync(["bun", "run", "--cwd", App.configDir, "sass", inScss, outCss]);
    App.resetCss();
    App.applyCss(outCss);
});

try {
    console.log(["bun", "run", "--cwd", App.configDir, "sass", inScss, outCss].join(" "));
    await Utils.execAsync(["bun", "run", "--cwd", App.configDir, "sass", inScss, outCss]);
    App.applyCss(outCss);

    console.log(["bun", "build", entry, "--outdir", outfile, "--external", "resource://*", "--external", "gi://*"].join(" "));
    await Utils.execAsync([
        "bun",
        "build",
        entry,
        "--outfile",
        outfile,
        "--external",
        "resource://*",
        "--external",
        "gi://*",
        "--external",
        "file://*",
    ]);
    await import(`file://${outfile}`);
} catch (error) {
    console.error(error);
    let current = "";
    try {
        current = await Utils.readFileAsync("/tmp/agserror.log");
    } catch (e) {}
    await Utils.writeFile(`${current} \n ${error}`, "/tmp/agserror.log");
}

export {};
