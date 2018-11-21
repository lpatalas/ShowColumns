using System.Management.Automation;

namespace ShowColumns.Commands
{
    internal delegate TextStyle TextStyleSelector(object inputObject);

    internal static class TextStyleSelectorFactory
    {
        public static TextStyleSelector Create(object selectorOrValue)
            => selectorOrValue is ScriptBlock scriptBlock
                ? CreateScriptBlockSelector(scriptBlock)
                : CreateConstantSelector(selectorOrValue);

        private static TextStyleSelector CreateScriptBlockSelector(ScriptBlock scriptBlock)
            => inputObject
                =>
                {
                    var result = scriptBlock.InvokeWithInputObject(inputObject);
                    return TextStyle.FromObject(result);
                };

        private static TextStyleSelector CreateConstantSelector(object value)
        {
            var color = TextStyle.FromObject(value);
            return _ => color;
        }
    }
}
