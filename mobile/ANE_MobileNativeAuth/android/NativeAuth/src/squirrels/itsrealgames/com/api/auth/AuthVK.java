package squirrels.itsrealgames.com.api.auth;

import java.util.Arrays;

import com.vk.sdk.VKAccessToken;
import com.vk.sdk.VKScope;
import com.vk.sdk.VKSdk;
import com.vk.sdk.VKSdkListener;
import com.vk.sdk.VKUIHelper;

import android.content.Intent;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.vk.sdk.api.VKApi;
import com.vk.sdk.api.VKApiConst;
import com.vk.sdk.api.VKError;
import com.vk.sdk.api.VKParameters;
import com.vk.sdk.api.VKRequest;
import com.vk.sdk.api.VKRequest.VKRequestListener;
import com.vk.sdk.api.VKResponse;
import com.vk.sdk.dialogs.VKCaptchaDialog;
import com.vk.sdk.util.VKUtil;
/**
 * ...
 * @author Sprinter
 */
public class AuthVK implements AuthInterface {
	protected static final String TAG = "AuthVK";
	
	private final static String MSG_ERROR_TOKEN_EXPIRED = "token expired";
	private AuthInterface mCallBack = null;
	private String mAppId = "";
	private FREContext mContext;
	
	private static final String[] sMyScope = new String[] {
		VKScope.FRIENDS,
		VKScope.WALL,
		VKScope.PHOTOS,
		VKScope.NOHTTPS
	};
	
	public AuthVK(FREContext context, String appId, AuthInterface callBack) {
		String packageName = context.getActivity().getPackageName();
		mAppId = appId;
		mCallBack = callBack;
		mContext = context;
		VKUIHelper.onCreate(mContext.getActivity());
		
		
		String[] fingerprints = VKUtil.getCertificateFingerprint(context.getActivity(), packageName);
		String newString = Arrays.toString(fingerprints);
		newString = newString.substring(1, newString.length()-1);
		
		VKSdk.initialize(sdkListener, mAppId);
        
        if (VKSdk.wakeUpSession()) {
        	onSuccess(VKSdk.getAccessToken().accessToken);
            return;
        }
	}
	
	private final VKSdkListener sdkListener = new VKSdkListener() {
        @SuppressWarnings("deprecation")
		@Override
        public void onCaptchaError(VKError captchaError) {
            new VKCaptchaDialog(captchaError).show();
        }

        @Override
        public void onTokenExpired(VKAccessToken expiredToken) {
            VKSdk.authorize(sMyScope);
        }

        @Override
        public void onAccessDenied(final VKError authorizationError) {
        	onFail(authorizationError.errorMessage.toString());
        }

        @Override
        public void onReceiveNewToken(VKAccessToken newToken) {
        	onSuccess(newToken.accessToken);
        }

        @Override
        public void onAcceptUserToken(VKAccessToken token) {
        	onSuccess(token.accessToken);
        }
    };

    @Override
	public void logout() {
    	VKSdk.logout();
	}
    
	@Override
	public void login(final String[] params) {
		VKSdk.authorize(sMyScope);
	}
	
	@Override
	public void onSuccess(final String token) {
		mCallBack.onSuccess(token);
	}
	
	@Override
	public void onFail(final String msg) {
		mCallBack.onFail(msg);
	}
	
	@Override
	public void onResume() {
		VKUIHelper.onResume(mContext.getActivity());
		if (!VKSdk.isLoggedIn()) {
			onFail(MSG_ERROR_TOKEN_EXPIRED);
		}
	}
	
	@Override
	public void onDestroy() {
		 VKUIHelper.onDestroy(mContext.getActivity());
	}

	@Override
	public Boolean isLoggedIn() {
		return VKSdk.isLoggedIn();
	}

	@SuppressWarnings("deprecation")
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		VKUIHelper.onActivityResult(requestCode, resultCode, intent);
	}

	@Override
	public void getUser() {
		 VKRequest request = VKApi.users().get(VKParameters.from(VKApiConst.FIELDS,
             "id,first_name,last_name,sex,bdate,city,country"));
		 
         request.secure = false;
         request.useSystemLanguage = true;
         
         request.executeWithListener(new VKRequestListener() //немного говонокода (перевести на отдельный класс)
     		{
	     		@Override
	     		public void onComplete(VKResponse response)
	     		{
	     			onGetUser(response.responseString);
	     		}
	
	     		@Override
	     		public void onError(VKError error)
	     		{
	     			Log.e(TAG, "ERROR: " + error.errorMessage);
	     		}
	
	     		@Override
	     		public void onProgress(VKRequest.VKProgressType progressType, long bytesLoaded,
	     		                       long bytesTotal)
	     		{
	     			// you can show progress of the request if you want
	     		}
	
	     		@Override
	     		public void attemptFailed(VKRequest request, int attemptNumber, int totalAttempts)
	     		{
	     			
	     		}
     		});

	}

	@Override
	public void onGetUser(String response) {
		mCallBack.onGetUser(response);
	}
	 
}
