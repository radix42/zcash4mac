package com.vaklinov.zcashui;

import java.awt.BorderLayout;
import java.awt.Container;
import java.io.File;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.net.URL;
import java.util.Map;

import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JWindow;
import javax.swing.SwingUtilities;

import com.eclipsesource.json.JsonObject;
import com.eclipsesource.json.JsonValue;
import com.vaklinov.zcashui.OSUtil.OS_TYPE;
import com.vaklinov.zcashui.ZCashClientCaller.WalletCallException;

public class StartupProgressDialog extends JWindow {

    private static final int POLL_PERIOD = 250;
    private static final int STARTUP_ERROR_CODE = -28;
    private static final int PROVING_KEY_SIZE = 910173851;
    
    private BorderLayout borderLayout1 = new BorderLayout();
    private JLabel imageLabel = new JLabel();
    private JLabel progressLabel = new JLabel();
    private JPanel southPanel = new JPanel();
    private BorderLayout southPanelLayout = new BorderLayout();
    private JProgressBar progressBar = new JProgressBar();
    private ImageIcon imageIcon;
    
    private final ZCashClientCaller clientCaller;
    
    public StartupProgressDialog(ZCashClientCaller clientCaller) {
        this.clientCaller = clientCaller;
        
        URL iconUrl = this.getClass().getClassLoader().getResource("images/Z-yellow.orange-logo.png");
        imageIcon = new ImageIcon(iconUrl);
        imageLabel.setIcon(imageIcon);
        Container contentPane = getContentPane();
        contentPane.setLayout(borderLayout1);
        southPanel.setLayout(southPanelLayout);
        contentPane.add(imageLabel,BorderLayout.CENTER);
        contentPane.add(southPanel, BorderLayout.SOUTH);
        progressBar.setIndeterminate(true);
        southPanel.add(progressBar, BorderLayout.NORTH);
        progressLabel.setText("Starting...");
        southPanel.add(progressLabel, BorderLayout.SOUTH);
        setLocationRelativeTo(null);
        pack();
    }
    
    public void waitForStartup() throws IOException,
        InterruptedException,WalletCallException,InvocationTargetException {
        
        // special handling of OSX app bundle
        if (OSUtil.getOSType() == OS_TYPE.MAC_OS && 
                "true".equalsIgnoreCase(System.getProperty("launching.from.appbundle")))
            performOSXBundleLaunch();
        
        System.out.println("trying to start zcashd");
        final Process daemonProcess = clientCaller.startDaemon();
        while(true) {
            Thread.sleep(POLL_PERIOD);
            JsonObject info = clientCaller.getInfo();
            JsonValue code = info.get("code");
            if (code == null || (code.asInt() != STARTUP_ERROR_CODE))
                break;
            final String message = info.getString("message", "???");
            SwingUtilities.invokeLater(new Runnable() {
                public void run() {
                    progressLabel.setText(message);
                }
            });
        }
        System.out.println("zcashd started");
        SwingUtilities.invokeAndWait(new Runnable() {
            public void run() {
                dispose();
            }
        });
        Runtime.getRuntime().addShutdownHook(new Thread() {
            public void run() {
                if (daemonProcess.isAlive()) {
                    System.out.println("Stopping zcashd because we started it");
                    try {
                        clientCaller.stopDaemon();
                    } catch (Exception bad) {
                        System.out.println("Couldn't stop zcashd!");
                        bad.printStackTrace();
                    }
                } else
                    System.out.println("not stopping zcashd");
            }
        });
    }
    
    private void performOSXBundleLaunch() throws IOException, InterruptedException {
        
        
        File bundlePath = new File(System.getProperty("zcash.location.dir"));
        bundlePath = bundlePath.getCanonicalFile();
        
        JOptionPane.showMessageDialog(null, "Running OSX Bundle-specific intialization\n" +
                "bundlePath is "+bundlePath.getCanonicalPath());
        
        // run "first-run.sh"
        File firstRun = new File(bundlePath,"first-run.sh");
        Process firstRunProcess = Runtime.getRuntime().exec(firstRun.getCanonicalPath());
        firstRunProcess.waitFor();
        
        JOptionPane.showMessageDialog(null, "successfully executed first-run.sh");
        
        // then run fetch-params.sh
        File fetchParams = new File(bundlePath,"fetch-params.sh");
        ProcessBuilder pb = new ProcessBuilder(fetchParams.getCanonicalPath());
        Map<String, String> env = pb.environment();
        String path = env.get("PATH");
        path = path + ":"+bundlePath.getCanonicalPath();
        env.put("PATH", path);
        Process fetchParamsProcess = pb.start();
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                progressBar.setIndeterminate(false);
                progressLabel.setText("Fetching parameters...");
            }
        });
        while(true) {
            
            File provingKey = new File(System.getProperty("user.home")+
                    "/Library/Application Support/ZcashParams/sprout-proving.key");
            provingKey = provingKey.getCanonicalFile();
            
            File provingKeyDL = new File(System.getProperty("user.home")+
                    "/Library/Application Support/ZcashParams/sprout-proving.key.dl");
            provingKeyDL = provingKeyDL.getCanonicalFile();
            
            if (provingKey.exists() && provingKey.length() == PROVING_KEY_SIZE) {
                JOptionPane.showMessageDialog(null,"Full proving key found!");
                break;
            }
            
            if (provingKeyDL.exists()) {
                long length = provingKeyDL.length();
                final int percent = (int)(length * 100.0 / PROVING_KEY_SIZE);
                SwingUtilities.invokeLater(new Runnable() {
                    public void run() {
                        progressLabel.setText("Fetching parameters "+percent+"%");
                        progressBar.setValue(percent);
                    }
                });
            } else JOptionPane.showMessageDialog(null, "No keys found, sleeping ");
            Thread.sleep(POLL_PERIOD);
        }
        fetchParamsProcess.waitFor();
        JOptionPane.showMessageDialog(null, "fetch-params process ended!");
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                progressBar.setIndeterminate(true);
            }
        });
    }
}
