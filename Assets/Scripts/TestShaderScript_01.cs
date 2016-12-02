using UnityEngine;
using System.Collections;

/// <summary>
/// テストシェーダ用のスクリプト
/// </summary>
[RequireComponent(typeof(MeshFilter))]
public class TestShaderScript_01 : MonoBehaviour {

	private void Start() {

		var mesh = GetComponent<MeshFilter>().mesh;

		int size = mesh.vertexCount;
		Vector2[] uv2 = new Vector2[size];
		for (int i = 0; i < size; ++i) {
			uv2[i] = new Vector2(Random.Range(0f, 1f), i);
		}
		mesh.uv2 = uv2;
	}
}