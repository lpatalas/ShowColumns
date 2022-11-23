using System;
using System.Collections;
using System.Management.Automation;
using System.Text;

namespace ShowColumns.Commands
{
    public struct TextStyle
    {
        private const char ESC = (char)0x1b;

        public static readonly TextStyle Default = new TextStyle();
        public static readonly TextStyle Reset = new TextStyle($"{ESC}[0m");

        private readonly string value;

        public bool IsEmpty => string.IsNullOrEmpty(value);

        public TextStyle(ConsoleColor foregroundColor)
        {
            value = $"{ESC}[{ForegroundColorCode(foregroundColor)}m";
        }

        public TextStyle(ConsoleColor foregroundColor, ConsoleColor backgroundColor)
        {
            var fgCode = ForegroundColorCode(foregroundColor);
            var bgCode = BackgroundColorCode(backgroundColor);
            value = $"{ESC}[{fgCode};{bgCode}m";
        }

        public TextStyle(IDictionary dictionary)
        {
            var fgColor = TryConvertToConsoleColor(
                dictionary.GetValueOrDefault("Foreground"));

            var bgColor = TryConvertToConsoleColor(
                dictionary.GetValueOrDefault("Background"));
            
            var isUnderlined = dictionary.GetValueOrDefault<bool>("Underline");

            if (fgColor.HasValue || bgColor.HasValue || isUnderlined)
            {
                var escapeCodeBuilder = new StringBuilder($"{ESC}[");
                if (fgColor.HasValue)
                    escapeCodeBuilder.Append(ForegroundColorCode(fgColor.Value));
                if (bgColor.HasValue)
                {
                    if (fgColor.HasValue)
                        escapeCodeBuilder.Append(';');
                    escapeCodeBuilder.Append(BackgroundColorCode(bgColor.Value));
                }
                if (isUnderlined)
                {
                    if (fgColor.HasValue || bgColor.HasValue)
                        escapeCodeBuilder.Append(';');
                    escapeCodeBuilder.Append(4);
                }

                escapeCodeBuilder.Append('m');
                value = escapeCodeBuilder.ToString();
            }
            else
            {
                value = string.Empty;
            }
        }

        public TextStyle(string colorNameOrEscapeCode)
        {
            var fgColor = TryConvertToConsoleColor(colorNameOrEscapeCode);
            if (fgColor.HasValue)
                value = $"{ESC}[{ForegroundColorCode(fgColor.Value)}m";
            else if (colorNameOrEscapeCode.Length > 0 && colorNameOrEscapeCode[0] == ESC)
                value = colorNameOrEscapeCode;
            else
                value = string.Empty;
        }

        public static TextStyle FromObject(object inputObject)
        {
            if (inputObject != null)
            {
                if (inputObject is PSObject psObject)
                    return FromObject(psObject.BaseObject);
                else if (inputObject is ConsoleColor foregroundColor)
                    return new TextStyle(foregroundColor);
                else if (inputObject is string foregroundColorName)
                    return new TextStyle(foregroundColorName);
                else if (inputObject is IDictionary dictionary)
                    return new TextStyle(dictionary);
            }

            return TextStyle.Default;
        }

        public override string ToString()
            => value ?? string.Empty;

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

        private static int BackgroundColorCode(ConsoleColor color)
            => ForegroundColorCode(color) + 10;

        private static int ForegroundColorCode(ConsoleColor color)
        {
            switch (color)
            {
                case ConsoleColor.Black:
                    return 30;
                case ConsoleColor.Blue:
                    return 94;
                case ConsoleColor.Cyan:
                    return 96;
                case ConsoleColor.DarkBlue:
                    return 34;
                case ConsoleColor.DarkCyan:
                    return 36;
                case ConsoleColor.DarkGray:
                    return 90;
                case ConsoleColor.DarkGreen:
                    return 32;
                case ConsoleColor.DarkMagenta:
                    return 35;
                case ConsoleColor.DarkRed:
                    return 31;
                case ConsoleColor.DarkYellow:
                    return 33;
                case ConsoleColor.Gray:
                    return 37;
                case ConsoleColor.Green:
                    return 92;
                case ConsoleColor.Magenta:
                    return 95;
                case ConsoleColor.Red:
                    return 91;
                case ConsoleColor.White:
                    return 97;
                case ConsoleColor.Yellow:
                    return 93;
                default:
                    return 37;
            }
        }
    }
}
