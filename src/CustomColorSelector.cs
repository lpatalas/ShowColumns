using System.Management.Automation;

namespace ShowColumns
{
    internal delegate CustomColor CustomColorSelector(object inputObject);

    internal static class CustomColorSelectorFactory
    {
        public static CustomColorSelector Create(object selectorOrValue)
            => selectorOrValue is ScriptBlock scriptBlock
                ? CreateScriptBlockSelector(scriptBlock)
                : CreateConstantSelector(selectorOrValue);
                

        private static CustomColorSelector CreateScriptBlockSelector(ScriptBlock scriptBlock)
            => inputObject
                =>
                {
                    var result = scriptBlock.InvokeWithInputObject(inputObject);
                    return CustomColor.FromObject(result);
                };

        private static CustomColorSelector CreateConstantSelector(object value)
        {
            var color = CustomColor.FromObject(value);
            return _ => color;
        }
    }
}
