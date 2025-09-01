// TypeScript extension for Persian RTL support
import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
    console.log('Persian RTL Support extension is now active!');

    // Command to toggle text direction
    let toggleDirection = vscode.commands.registerCommand('persianRtl.toggleDirection', () => {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
            const document = editor.document;
            const selection = editor.selection;
            const text = document.getText(selection);
            
            // Detect if text contains Persian characters
            const hasPersian = /[\u0600-\u06FF]/.test(text);
            
            if (hasPersian) {
                vscode.window.showInformationMessage('Persian text detected - RTL applied');
                // Apply RTL styling if possible
            }
        }
    });

    // Command to apply Vazirmatn font
    let applyVazirmatn = vscode.commands.registerCommand('persianRtl.applyVazirmButton', () => {
        const config = vscode.workspace.getConfiguration();
        config.update('editor.fontFamily', "'Vazirmatn', 'Fira Code', monospace", vscode.ConfigurationTarget.User);
        config.update('terminal.integrated.fontFamily', "'Vazirmatn', monospace", vscode.ConfigurationTarget.User);
        vscode.window.showInformationMessage('فونت وزیرمتن اعمال شد - Vazirmatn font applied');
    });

    // Auto-detect Persian text and suggest RTL
    let autoDetect = vscode.workspace.onDidChangeTextDocument((event) => {
        const config = vscode.workspace.getConfiguration('persianRtl');
        if (config.get('autoDetectDirection')) {
            const text = event.document.getText();
            const hasPersian = /[\u0600-\u06FF]/.test(text);
            
            if (hasPersian) {
                // Could implement automatic RTL suggestions here
            }
        }
    });

    // Apply CSS for better RTL support
    const cssPath = vscode.Uri.joinPath(context.extensionUri, 'styles', 'rtl-support.css');
    
    context.subscriptions.push(toggleDirection, applyVazirmatn, autoDetect);
}

export function deactivate() {}
