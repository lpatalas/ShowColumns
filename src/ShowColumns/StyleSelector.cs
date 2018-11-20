using System.Management.Automation;

namespace ShowColumns
{
    internal delegate Style StyleSelector(object inputObject);

    internal static class StyleSelectorFactory
    {
        public static StyleSelector Create(object selectorOrValue)
            => selectorOrValue is ScriptBlock scriptBlock
                ? CreateScriptBlockSelector(scriptBlock)
                : CreateConstantSelector(selectorOrValue);

        private static StyleSelector CreateScriptBlockSelector(ScriptBlock scriptBlock)
            => inputObject
                =>
                {
                    var result = scriptBlock.InvokeWithInputObject(inputObject);
                    return Style.FromObject(result);
                };

        private static StyleSelector CreateConstantSelector(object value)
        {
            var color = Style.FromObject(value);
            return _ => color;
        }
    }
}
