param($UserInput)

$characterTypoPatterns = @(

    ## The user forgot to type this character
    {
        param($UserInput)

        ""
    },

    ## The user doubled this character
    {
        param($UserInput)

        "$UserInput$UserInput"
    },

    ## Fat finger a letter (one off physically)
    {
        param($UserInput)

        $typoMap = @{
            '`' = "1`t"
            '1' = "``2`t"
            '2' = "1qw3"
            '3' = "2we4"
            '4' = "3er5"
            '5' = "4rt6"
            '6' = "5ty7"
            '7' = "6yu8"
            '8' = "7ui9"
            '9' = "8io0"
            '0' = "9op-"
            '-' = "0p[="

            ## Backspace is also a possible typo, but that would be handled by the
            ## "Forgot to type a character" filter
            '=' = "-[]"
            
            'q' = "``12`twas"
            'w' = "123qeasd"
            'e' = "234wrsdf"
            'r' = "345etdfg"
            't' = "567ryfgh"
            'y' = "678tughj"
            'u' = "789yihjk"
            'i' = "890uojkl"
            'o' = "90-ipkl;"
            'p' = "0-=o[l;'"
            '[' = "-=p];'`n"
            ']' = "=[\'`n"
            '\' = "]'`n"
            
            ## Shift is also a possible typo, but that would be handled by that character
            ## not being typed, so covered by "Forgot to type a character" filter.
            'a' = "`tqwszx"
            's' = "qweadzxc"
            'd' = "wersfxcv"
            'f' = "ertdgcvb"
            'g' = "rtyfhvbn"
            'h' = "tyugjbnm"
            'j' = "yuihknm,"
            'k' = "uiojlm,."
            'l' = "iopk;,./"
            ';' = "op[l'./"
            '''' = "[]\;`n./"

            'z' = "asx"
            'x' = "asdzc"
            'c' = "sdfxv "
            'v' = "dfgcb "
            'b' = "fghvn "
            'n' = "ghjbm "
            'm' = "hjkn, "
            ',' = "jklm."
            '.' = "kl;,/"
            '/' = ";'`n."
        }

        $capitalTypoMap = @{           
            '~' = "!`tQ"
            '!' = "~@`tQW"
            '@' = "!#QWE"           
            '#' = "@`$WER"
            '$' = "#%ERT"
            '%' = "`$^ERT"
            '^' = "%&RTY"
            '&' = "^*TYU"
            '*' = "&(YUI"
            '(' = "*)IOP"
            ')' = "(_OP{"
            '_' = ")+P{}"

            ## Backspace is also a possible typo, but that would be handled by the
            ## "Forgot to type a character" filter
            '+' = "_{}|"
            '{' = ")_+P}:`"`n"
            '}' = "+{|`"`n"
            '|' = "+}`"`n"

            ':' = "OP{L`">?"
            '"' = "P{}:`n>?"
            '<' = "JKLM>"
            '>' = "KL:<?"
            '?' = ":`"`n>"
        }

        if($typoMap.ContainsKey($UserInput.ToString()))
        {
            foreach($character in $typoMap[$UserInput.ToString()].ToCharArray())
            {
                $character
            }
        }
        elseif($capitalTypoMap.ContainsKey($UserInput.ToString()))
        {
            foreach($character in $capitalTypoMap[$UserInput.ToString()].ToCharArray())
            {
                $character
            }
        }
        else
        {
            $UserInput    
        }
    }
)

$globalTypoPatterns = @(

    ## The user accidentally had CAPS engaged at some point in the input
    {
        param($UserInput)

        for($capsPosition = 0; $capsPosition -lt $UserInput.Length; $capsPosition++)
        {
            $beginning = $UserInput.SubString(0, $capsPosition)

            $newChars = foreach($char in $UserInput.SubString($capsPosition, $UserInput.Length - $capsPosition).ToCharArray())
            {
                if([Char]::IsUpper($char)) { [Char]::ToLower($char) }
                elseif([Char]::IsLower($char)) { [Char]::ToUpper($char) }
                else { $char }
            }

            $beginning + (-join $newChars)
        }
    },

    ## Was a System.SecureString, converted to text via .ToString()
    {
        param($UserInput)

        "System.SecureString"
    }

    ## Had spaces before or after (maybe from pasting)
    {
        param($UserInput)

        for($prePadding = 0; $prePadding -lt 3; $prePadding++)
        {
            for($postPadding = 0; $postPadding -lt 3; $postPadding++)
            {
                (" " * $prePadding) + $UserInput + (" " * $postPadding)
            }           
        }
    }    

    ## Had alternate keyboard engaged
    {
        param($UserInput)

        $inputMaps = @{
            'en-US'  = '`1234567890-=qwertyuiop[]\asdfghjkl;''zxcvbnm,./~!@#$%^&*()_+QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?'
            'es-ES'  = '|1234567890''¿qwertyuiop´+}asdfghjklñ{zxcvbnm,.-°!"#$%&/()=?¡QWERTYUIOP¨*]ASDFGHJKLÑ[ZXCVBNM;:_'
            'Dvorak' = '`1234567890[]'',.pyfgcrl/=\aoeuidhtns-;qjkxbmwvz~!@#$%^&*(){}"<>PYFGCRL?+|AOEUIDHTNS_:QJKXBMWVZ'
        }

        foreach($sourceKeyboard in $inputMaps.Keys)
        {
            foreach($destinationKeyboard in $inputMaps.Keys)
            {
                if($sourceKeyboard -eq $destinationKeyboard)
                {
                    continue
                }

                $chars = foreach($inputChar in $UserInput.ToCharArray()) {
                    $inputIndex = $inputMaps[$sourceKeyboard].IndexOf($inputChar)
                    if($inputIndex -ge 0)
                    {
                        $inputMaps[$destinationKeyboard][$inputIndex]
                    }
                    else
                    {
                        $inputChar    
                    }
                }

                $result = -join $chars
                if($result -cne $UserInput)
                {
                    $result
                }
            }
        }
    },

    ## User input got truncated to some maximum length
    {
        param($UserInput)

        for($truncation = 0; $truncation -lt $UserInput.Length; $truncation++)
        {
            $UserInput.Substring(0, $truncation)
        }
    }    
      
)

## Emit the input as guessed by the user.
$UserInput

## Go through character typo patterns
foreach($characterTypoPattern in $characterTypoPatterns)
{
    for($charPosition = 0; $charPosition -lt $UserInput.Length; $charPosition++)
    {
        $preInput = $UserInput.Substring(0, $charPosition)

        $postInput = ""
        if($charPosition -lt ($UserInput.Length - 1))
        {
            $postInput = $UserInput.Substring($charPosition + 1, ($UserInput.Length - $charPosition - 1));
        }

        $results = & $characterTypoPattern $UserInput[$charPosition]
        foreach($result in $results)
        {
            $preInput + $result + $postInput
        }
    }
}

## Go through global typo patterns
foreach($globalTypoPattern in $globalTypoPatterns)
{
    $results = & $globalTypoPattern $UserInput
    foreach($result in $results)
    {
        $result
    }   
}
