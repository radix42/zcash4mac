package com.vaklinov.zcashui;

import java.awt.Component;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InterruptedIOException;
import java.io.OutputStream;

import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JProgressBar;
import javax.swing.ProgressMonitorInputStream;

import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

/**
 * Fetches the proving key.  Deliberately hardcoded.
 * @author zab
 */
public class ProvingKeyFetcher {
    
    
    private static final int PROVING_KEY_SIZE = 910173851;
    private static final String SHA256 = "8bc20a7f013b2b58970cddd2e7ea028975c88ae7ceb9259a5344a16bc2c0eef7";
    private static final String URL = "https://zcash.dl.mercerweiss.com/sprout-proving.key";
    // TODO: add backups
    
    public void fetchIfMissing(Component parent) throws IOException,InterruptedException {
        File zCashParams = new File(System.getProperty("user.home") + "/Library/Application Support/ZcashParams");
        zCashParams = zCashParams.getCanonicalFile();
        
        boolean needsFetch = false;
        if (!zCashParams.exists()) {
            needsFetch = true;
            zCashParams.mkdirs();
        }
        
        // verifying key is small, always copy it
        File verifyingKeyFile = new File(zCashParams,"sprout-verifying.key");
        FileOutputStream fos = new FileOutputStream(verifyingKeyFile);
        InputStream is = ProvingKeyFetcher.class.getClassLoader().getResourceAsStream("sprout-verifying.key");
        copy(is,fos);
        fos.close();
        
        File provingKeyFile = new File(zCashParams,"sprout-proving.key");
        provingKeyFile = provingKeyFile.getCanonicalFile();
        if (!provingKeyFile.exists())
            needsFetch = true;
        else if (provingKeyFile.length() != PROVING_KEY_SIZE)
            needsFetch = true;
        else {
            needsFetch = !checkSHA256(provingKeyFile);
        }
        
        if (!needsFetch) 
            return;
        
        JOptionPane.showMessageDialog(parent, "Zcash needs to download a large file.  This will happen only once.\n  "
                + "Please be patient.  Press OK to continue");
        
        provingKeyFile.delete();
        OutputStream os = new BufferedOutputStream(new FileOutputStream(provingKeyFile));
        CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpGet get = new HttpGet(URL);
        CloseableHttpResponse response = null;
        try {
            response = httpClient.execute(get);
            is = response.getEntity().getContent();
            ProgressMonitorInputStream pmis = new ProgressMonitorInputStream(parent, "Downloading proving key", is);
            pmis.getProgressMonitor().setMaximum(PROVING_KEY_SIZE);
            pmis.getProgressMonitor().setMillisToPopup(10);
            copy(pmis,os);
            os.close();
        } catch (InterruptedIOException cancelled) {
            JOptionPane.showMessageDialog(null, "Zcash cannot proceed without a proving key.");
            System.exit(-3);
        } finally {
            try {if (response != null)response.close();} catch (IOException ignore){}
            try {httpClient.close();} catch (IOException ignore){}
        }
        if (!checkSHA256(provingKeyFile)) {
            JOptionPane.showMessageDialog(parent, "Failed to download proving key.  Cannot continue");
            System.exit(-4);
        }
    }
            

    private static void copy(InputStream is, OutputStream os) throws IOException {
        byte[] buf = new byte[0x1 << 13];
        int read;
        while ((read = is.read(buf)) >- 0) {
            os.write(buf,0,read);
        }
        os.flush();
    }
    
    private static boolean checkSHA256(File provingKey) throws IOException, InterruptedException {
        CommandExecutor executor = new CommandExecutor(new String[]
                {"shasum","-a","256",provingKey.getCanonicalPath()});
        String sum = executor.execute();
        return sum.startsWith(SHA256);
    }
}
