using UnityEngine;
using System.Collections;

namespace StoreKitPlugin
{

	public class AppStartBehaviour : MonoBehaviour
	{
		void Start ()
		{
			StoreKitManager.SharedInstance.RequestProducts();
		}
	}

}
