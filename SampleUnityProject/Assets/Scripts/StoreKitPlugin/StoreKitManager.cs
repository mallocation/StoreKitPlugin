using UnityEngine;
using System.Runtime.InteropServices;
using System;

#if UNITY_IOS
namespace StoreKitPlugin
{
	public class StoreKitManager
	{

		#region DllImports
		
		// These are the interface to native implementation calls for iOS.
		[DllImport("__Internal")]
		private static extern void _SetCallbackObjectName(string name);
		
		[DllImport("__Internal")]
		private static extern void _BuyProductWithIdentifier(string identifier);
		
		[DllImport("__Internal")]
		private static extern void _RequestProducts();

		#endregion

		public event Action<object, string> PurchaseSuccessful;
		
		private static StoreKitManager _sharedInstance;
		public static StoreKitManager SharedInstance 
		{
			get
			{
				if (_sharedInstance == null)
				{
					_sharedInstance = new StoreKitManager();
				}
				return _sharedInstance;
			}
		}
		
		private StoreKitManager(){}
		
		public void RequestProducts()
		{
			Debug.Log("StoreKitManager RequestProducts...");
			
			_RequestProducts();
		}
		
		public void SetCallbackObjectName(string name)
		{
			_SetCallbackObjectName(name);
		}
		
		public void BuyProductWithIdentifier(string identifier)
		{
			_BuyProductWithIdentifier(identifier);
		}

		public void NotifyPurchaseSuccessful(string identifier)
		{
			if (this.PurchaseSuccessful != null)
			{
				this.PurchaseSuccessful(this, identifier);
			}
		}

	}
}
#endif