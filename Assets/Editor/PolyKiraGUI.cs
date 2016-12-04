using UnityEngine;
using UnityEditor;
using System.Collections;

public class PolyKiraGUI : ShaderGUI {

	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
		//base.OnGUI(materialEditor, properties);

		Material mat = (Material)materialEditor.target;
		
		//色関連
		EditorGUILayout.LabelField("HSVColor");
		//色相
		EditorGUILayout.LabelField("Hue(色相)");
		DrawMinMax(mat, "_HueMin", "_HueMax", 0f, 1f);
		//彩度
		EditorGUILayout.LabelField("Saturation(彩度)");
		DrawMinMax(mat, "_SatMin", "_SatMax", 0f, 1f);
		//明度
		EditorGUILayout.LabelField("Value(明度)");
		DrawMinMax(mat, "_ValMin", "_ValMax", 0f, 1f);

		//アニメーション関連
		EditorGUILayout.LabelField("Animation");
		//乱雑さ
		EditorGUILayout.LabelField("Randomness(乱雑さ)");
		DrawSlider(mat, "_Randomness", 0f, 0.5f);
		//時間倍率
		EditorGUILayout.LabelField("TimeScale(時間倍率)");
		DrawSlider(mat, "_TimeScale", 0f, 100f);

	}

	private void DrawSlider(Material mat, string prop, float min, float max) {
		float val = mat.GetFloat(prop);
		val = EditorGUILayout.Slider(val, min, max);
		mat.SetFloat(prop, val);
	}

	/// <summary>
	/// 最小-最大の描画
	/// </summary>
	private void DrawMinMax(Material mat, string minProp, string maxProp, float minLimit, float maxLimit) {
		float min = mat.GetFloat(minProp);
		float max = mat.GetFloat(maxProp);
		EditorGUILayout.MinMaxSlider(ref min, ref max, minLimit, maxLimit);
		mat.SetFloat(minProp, min);
		mat.SetFloat(maxProp, max);
	}
}