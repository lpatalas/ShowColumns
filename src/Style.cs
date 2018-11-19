using System;
using System.Collections;
using System.Management.Automation;

namespace ShowColumns
{
    public struct Style
    {
        public ConsoleColor? Foreground { get; }
        public ConsoleColor? Background { get; }
        public bool Underline { get; }

        public bool IsDefault
            => !Foreground.HasValue
            && !Background.HasValue
            && !Underline;

        public static readonly Style Default = new Style();

        public Style(ConsoleColor foregroundColor)
        {
            this.Foreground = foregroundColor;
            this.Background = null;
            this.Underline = false;
        }

        public Style(ConsoleColor foregroundColor, ConsoleColor backgroundColor)
        {
            this.Foreground = foregroundColor;
            this.Background = backgroundColor;
            this.Underline = false;
        }

        public Style(IDictionary dictionary)
        {
            this.Foreground = TryConvertToConsoleColor(
                dictionary.GetValueOrDefault("Foreground"));

            this.Background = TryConvertToConsoleColor(
                dictionary.GetValueOrDefault("Background"));
            
            this.Underline = dictionary.GetValueOrDefault<bool>("Underline");
        }

        public Style(string foregroundColorName)
        {
            this.Foreground = TryConvertToConsoleColor(foregroundColorName);
            this.Background = null;
            this.Underline = false;
        }

        public static Style FromObject(object inputObject)
        {
            if (inputObject != null)
            {
                if (inputObject is PSObject psObject)
                    return FromObject(psObject.BaseObject);
                else if (inputObject is ConsoleColor foregroundColor)
                    return new Style(foregroundColor);
                else if (inputObject is string foregroundColorName)
                    return new Style(foregroundColorName);
                else if (inputObject is IDictionary dictionary)
                    return new Style(dictionary);
            }

            return Style.Default;
        }

        private static ConsoleColor? TryConvertToConsoleColor(object value)
        {
            if (value is ConsoleColor consoleColor)
            {
                return consoleColor;
            }
            else if (value is string colorString
                && Enum.TryParse<ConsoleColor>(colorString, out var parsedConsoleColor))
            {
                return parsedConsoleColor;
            }
            else
            {
                return null;
            }
        }
    }
}
