using UnityEngine;
using System.Collections;
using StoreKitPlugin;

public class StoreButton : MonoBehaviour
{

	// Use this for initialization
	void Start ()
	{
		StoreKitManager.SharedInstance.PurchaseSuccessful += StoreKitManager_OnPurchaseSuccessful;
	}

	void OnDestroy()
	{
		StoreKitManager.SharedInstance.PurchaseSuccessful -= StoreKitManager_OnPurchaseSuccessful;
	}

	void OnMouseDown()
	{
		// Purchase an item here
		StoreKitManager.SharedInstance.BuyProductWithIdentifier("com.mallocation.the.identifier");
	}

	void StoreKitManager_OnPurchaseSuccessful (object sender, string identifier)
	{
		// This method will get called when a purchase is successful.
		// Possibly, toggle a button sprite here.
	}
}

