const core = require('@actions/core');
const fs = require('fs');
const path = require("path");

const fileName = core.getInput('name');
const dir = core.getInput('dir');
const fullPath = path.join(process.env.GITHUB_WORKSPACE, dir || "", fileName);

const jsonString = process.env.JSONSTRING;

let fileContent = JSON.stringify(jsonString);

fileContent = JSON.parse(fileContent)

try {
    core.info('Creating json file...')
    fs.writeFile(fullPath, fileContent, function (error) {

        if (error) {
            core.setFailed(error.message);
            throw error
        }

        core.info('JSON file created.')

        fs.readFile(fullPath, null, handleFile)

        function handleFile(err, data) {
            if (err) {
                core.setFailed(error.message)
                throw err
            }

            core.info('JSON checked.')
            core.setOutput("successfully", `Successfully created json on ${fullPath} directory with ${fileContent} data`);
        }
    });
} catch (err) {
    core.setFailed(err.message);
}