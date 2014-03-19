using UnityEngine;
using System.Collections;


#if UNITY_IOS

namespace StoreKitPlugin
{

	public class StoreKitPluginBridge : MonoBehaviour
	{
		void Start()
		{
			StoreKitManager.SharedInstance.SetCallbackObjectName(this.gameObject.name);
		}

		void OnProvideContentForProductIdentifier(string identifier)
		{
			Debug.Log("OnProvideContentForProductIdentifier: " + identifier);

			// Notify StoreKitManager
			StoreKitManager.SharedInstance.NotifyPurchaseSuccessful(identifier);
		}
	}

}
#endif