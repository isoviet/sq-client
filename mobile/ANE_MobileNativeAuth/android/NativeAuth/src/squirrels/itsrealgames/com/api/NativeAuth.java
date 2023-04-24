package squirrels.itsrealgames.com.api;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
/**
 * ...
 * @author Sprinter
 */
public class NativeAuth implements FREExtension {

	public static NativeAuthContext context;
	
	public FREContext createContext(String arg0) {
		Log.i("NativeAuth createContext", arg0);
		return context = new NativeAuthContext();
	}

	@Override
	public void dispose() {
		// TODO Auto-generated method stub
		
	}

	public void initialize() {
		// TODO Auto-generated method stub
		
	}
}
