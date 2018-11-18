using System.Management.Automation;

namespace ShowColumns
{
    internal delegate CustomColor CustomColorSelector(PSObject inputObject);

    internal static class CustomColorSelectorFactory
    {
        public static CustomColorSelector Create(ScriptBlock scriptBlock)
            => scriptBlock != null
                ? CreateScriptBlockSelector(scriptBlock)
                : _ => CustomColor.Default;

        private static CustomColorSelector CreateScriptBlockSelector(ScriptBlock scriptBlock)
            => inputObject
                =>
                {
                    var result = scriptBlock.InvokeWithInputObject(inputObject);
                    return CustomColor.FromPSObject(result);
                };
    }
}
