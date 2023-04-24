package squirrels.itsrealgames.com.api;

import java.util.HashMap;
import java.util.Map;

import android.content.Intent;
import android.content.res.Configuration;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.air.ActivityResultCallback;  
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.AndroidActivityWrapper.ActivityState;  
import com.adobe.air.StateChangeCallback;  
/**
 * ...
 * @author Sprinter
 */
public class NativeAuthContext  extends FREContext implements ActivityResultCallback, StateChangeCallback   {

	private final static String PUBLIC_METHOD_NAME = "actions";
	
	private NativeAuthActions mInstance = null;
	private AndroidActivityWrapper aaw;
	
	public NativeAuthContext() {  
        aaw = AndroidActivityWrapper.GetAndroidActivityWrapper();  
        aaw.addActivityResultListener( this );  
        aaw.addActivityStateChangeListner( this );  
    }  
	
	@Override
	public void dispose() {
		// TODO Auto-generated method stub
	}
	
	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> map = new HashMap<String, FREFunction>();
		mInstance = new NativeAuthActions();
		map.put(PUBLIC_METHOD_NAME, mInstance);
		return map;
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		if (mInstance != null) {
			mInstance.onActivityResult(requestCode, resultCode, intent);
		}
	}

	@Override
	public void onActivityStateChanged(ActivityState state) {
		if (mInstance != null) {
			mInstance.onActivityStateChanged(state);
		}
	}

	@Override
	public void onConfigurationChanged(Configuration arg0) {
		if (aaw!=null) {
		    aaw.removeActivityResultListener( this );
		    aaw.removeActivityStateChangeListner( this );
		    aaw = null;
		}
	}

}
