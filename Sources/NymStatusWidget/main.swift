import SwiftUI
import AppKit
import Foundation

@main
struct NymStatusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var gatewayStatus: String = "..." {
        didSet {
            updateMenuBarTitle()
        }
    }
    private var mixnodeStatus: String = "..." {
        didSet {
            updateMenuBarTitle()
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        updateMenuBarTitle()
        
        setupMenu()
        startTimer()
    }
    
    private func updateMenuBarTitle() {
        if let button = statusItem.button {
            let attributedString = NSMutableAttributedString()
            
            // Gateway Icon and Status
            attributedString.append(getStatusIcon(for: gatewayStatus, isGateway: true))
            attributedString.append(NSAttributedString(string: " "))
            attributedString.append(getStatusText(for: gatewayStatus, isGateway: true))
            
            // Separator
            attributedString.append(NSAttributedString(string: "  "))
            
            // Mixnode Icon and Status
            attributedString.append(getStatusIcon(for: mixnodeStatus, isGateway: false))
            attributedString.append(NSAttributedString(string: " "))
            attributedString.append(getStatusText(for: mixnodeStatus, isGateway: false))
            
            button.attributedTitle = attributedString
        }
    }
    
    private func getStatusIcon(for status: String, isGateway: Bool) -> NSAttributedString {
        let iconSymbol = isGateway ? "network" : "staroflife"
        let color = getStatusColor(for: status, isGateway: isGateway)
        
        let attachment = NSTextAttachment()
        let configuration = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let image = NSImage(systemSymbolName: iconSymbol, accessibilityDescription: nil)?.withSymbolConfiguration(configuration)
        
        if let image = image {
            let coloredImage = image.copy() as! NSImage
            coloredImage.lockFocus()
            color.set()
            NSRect(origin: .zero, size: coloredImage.size).fill(using: .sourceAtop)
            coloredImage.unlockFocus()
            
            attachment.image = coloredImage
            let attachmentString = NSAttributedString(attachment: attachment)
            return attachmentString
        }
        
        return NSAttributedString(string: "•")
    }
    
    private func getStatusText(for status: String, isGateway: Bool) -> NSAttributedString {
        let text = isGateway ? "Gateway" : "Mixnode"
        let color = getStatusColor(for: status, isGateway: isGateway)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: NSFont.systemFont(ofSize: 12, weight: .medium)
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    private func getStatusColor(for status: String, isGateway: Bool) -> NSColor {
        if isGateway {
            switch status.lowercased() {
            case "entrygateway":
                return NSColor.systemGreen
            case "exitgateway":
                return NSColor.systemBlue
            case "null":
                return NSColor.systemGray
            default:
                return NSColor.systemOrange
            }
        } else {
            switch status.lowercased() {
            case "layer1":
                return NSColor.systemPink
            case "layer2":
                return NSColor.systemPurple
            case "layer3":
                return NSColor.systemTeal
            case "null":
                return NSColor.systemGray
            default:
                return NSColor.systemOrange
            }
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // Status section with details
        let gatewayStatusItem = NSMenuItem(title: "Gateway Status", action: nil, keyEquivalent: "")
        gatewayStatusItem.isEnabled = false
        menu.addItem(gatewayStatusItem)
        
        let mixnodeStatusItem = NSMenuItem(title: "Mixnode Status", action: nil, keyEquivalent: "")
        mixnodeStatusItem.isEnabled = false
        menu.addItem(mixnodeStatusItem)
        
        // Interactive items
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Refresh Now", action: #selector(refreshStatus), keyEquivalent: "r"))
        
        // Info section
        menu.addItem(NSMenuItem.separator())
        let infoItem = NSMenuItem(title: "Nym Network Information", action: #selector(openNymWebsite), keyEquivalent: "i")
        menu.addItem(infoItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        // Update the status items in the menu
        updateMenuDetails()
    }
    
    private func updateMenuDetails() {
        if let menu = statusItem.menu {
            if let gatewayItem = menu.item(at: 0) {
                let attributedTitle = NSMutableAttributedString()
                attributedTitle.append(getStatusIcon(for: gatewayStatus, isGateway: true))
                attributedTitle.append(NSAttributedString(string: " Gateway: "))
                
                let statusString = NSAttributedString(
                    string: getReadableStatus(gatewayStatus, isGateway: true),
                    attributes: [
                        .foregroundColor: getStatusColor(for: gatewayStatus, isGateway: true),
                        .font: NSFont.boldSystemFont(ofSize: 13)
                    ]
                )
                attributedTitle.append(statusString)
                gatewayItem.attributedTitle = attributedTitle
            }
            
            if let mixnodeItem = menu.item(at: 1) {
                let attributedTitle = NSMutableAttributedString()
                attributedTitle.append(getStatusIcon(for: mixnodeStatus, isGateway: false))
                attributedTitle.append(NSAttributedString(string: " Mixnode: "))
                
                let statusString = NSAttributedString(
                    string: getReadableStatus(mixnodeStatus, isGateway: false),
                    attributes: [
                        .foregroundColor: getStatusColor(for: mixnodeStatus, isGateway: false),
                        .font: NSFont.boldSystemFont(ofSize: 13)
                    ]
                )
                attributedTitle.append(statusString)
                mixnodeItem.attributedTitle = attributedTitle
            }
        }
    }
    
    private func getReadableStatus(_ status: String, isGateway: Bool) -> String {
        if status == "..." {
            return "Loading..."
        }
        
        if isGateway {
            switch status.lowercased() {
            case "entrygateway":
                return "Entry Gateway"
            case "exitgateway":
                return "Exit Gateway"
            case "null":
                return "Inactive"
            default:
                return status
            }
        } else {
            switch status.lowercased() {
            case "layer1":
                return "Layer 1"
            case "layer2":
                return "Layer 2"
            case "layer3":
                return "Layer 3"
            case "null":
                return "Inactive"
            default:
                return status
            }
        }
    }
    
    private func startTimer() {
        // Execute once immediately
        refreshStatus()
        
        // Then set up timer to run every hour
        timer = Timer.scheduledTimer(timeInterval: 1*60*60, target: self, selector: #selector(refreshStatus), userInfo: nil, repeats: true)
    }
    
    @objc private func refreshStatus() {
        fetchGatewayStatus()
        fetchMixnodeStatus()
    }
    
    private func fetchGatewayStatus() {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "curl -s \"https://validator.nymtech.net/api/v1/nym-nodes/annotation/NODE_ID\" | jq -r '.annotation.current_role'"]
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        
        do {
            try task.run()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if !output.isEmpty {
                    self.gatewayStatus = output
                } else {
                    self.gatewayStatus = "Error"
                }
            } else {
                self.gatewayStatus = "Error"
            }
            
            // Update UI on main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.updateMenuDetails()
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.gatewayStatus = "Error"
                self.updateMenuDetails()
            }
        }
    }
    
    private func fetchMixnodeStatus() {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "curl -s \"https://validator.nymtech.net/api/v1/nym-nodes/annotation/NODE_ID\" | jq -r '.annotation.current_role'"]
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        
        do {
            try task.run()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if !output.isEmpty {
                    self.mixnodeStatus = output
                } else {
                    self.mixnodeStatus = "Error"
                }
            } else {
                self.mixnodeStatus = "Error"
            }
            
            // Update UI on main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.updateMenuDetails()
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.mixnodeStatus = "Error"
                self.updateMenuDetails()
            }
        }
    }
    
    @objc private func openNymWebsite() {
        if let url = URL(string: "https://nymtech.net") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
