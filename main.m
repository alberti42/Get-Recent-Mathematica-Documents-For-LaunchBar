//
//  main.m
//  GetRecentMathematicaDocuments
//
//  Created by Andrea Alberti on 18.02.18.
//  Copyright © 2018 Andrea Alberti. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* const RecentDocumentsFile = @"~/Library/Wolfram/FrontEnd/init.m";

NSCharacterSet* hexadecimal;
NSDictionary* MathematicaCommands;

//NSString* StripMathematicaString(NSMutableString* s) __attribute__((ns_returns_retained))
//{
////    s = [[s stringByReplacingOccurrencesOfString:@"\\[SZ]" withString:@"ß"] copy];
////    s = [[s stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"] copy];
////    s = [[s stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""] copy];
//
//    //    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&[^;]*;" options:NSRegularExpressionCaseInsensitive error:&error];
//    //    NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
//
//    return s;
//}

int change_endian(int input)
{
    char* p = (char*)(&input);
    int tmp;
    for (size_t i = 0; i < sizeof(short int) / 2; ++i)
    {
        tmp = p[i];
        p[i] = p[sizeof(short int) - i - 1];
        p[sizeof(short int) - i - 1] = tmp;
    }
    return input;
}

NSString* ReadMathematicaString(NSScanner* stringScanner, NSString* __nullable __strong* missingCommand) __attribute__((ns_returns_retained))
{
    NSString* string1;
    NSString* string2;
    unsigned int foundInteger;
    
    bool StringFound1;
    // bool StringFound2;
    
    NSMutableString* string = [NSMutableString string];
    
    NSScanner *scanner = [NSScanner alloc];
    [scanner setCharactersToBeSkipped:nil];
    
    NSCharacterSet* searchChr = [NSCharacterSet characterSetWithCharactersInString:@"\"\\:.[\n"];
    
    int numberOfQuotes = 0;
    
    *missingCommand = nil;

    while([stringScanner isAtEnd]==NO && numberOfQuotes<2)
    {
        StringFound1 = [stringScanner scanUpToCharactersFromSet:searchChr intoString:&string1];
        
        if([stringScanner scanCharactersFromSet:searchChr intoString:&string2])
        {
            //NSLog(@"%@",string1);
            //NSLog(@"%@",string2);
            //NSLog(@"****%@",[init_file substringWithRange:NSMakeRange([stringScanner scanLocation], 20)]);
            
            if(numberOfQuotes>0)
            {
                if(StringFound1)
                {
                    [string appendString:string1];
                }
            }
            
            if([string2 hasPrefix:@"\""])
            {
                numberOfQuotes++;
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+1];
            }
            else if([string2 hasPrefix:@"\n"])
            {
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+1];
            }
            else if([string2 hasPrefix:@"\\\n"])
            {
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+2];
            }
            else if([string2 hasPrefix:@"\""])
            {
                numberOfQuotes++;
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+1];
            }
            else if([string2 hasPrefix:@"."])
            {
                [string appendString:@"."];
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+1];
            }
            else if([string2 hasPrefix:@"\\\""])
            {
                [string appendString:@"\""];
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+2];
            }
            else if([string2 hasPrefix:@"\\\\"])
            {
                [string appendString:@"\\"];
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+2];
            }
            else if([string2 hasPrefix:@"\\:"])
            {
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+2];
                
                StringFound1 = [stringScanner scanUpToCharactersFromSet:hexadecimal intoString:&string1];
                if(StringFound1 && [string1 length]>=4)
                {
                    scanner = [scanner initWithString:[string1 substringToIndex:4]];
                    foundInteger = 0;
                    [scanner scanHexInt:&foundInteger];
                    [stringScanner setScanLocation:[stringScanner scanLocation]-[string1 length]+4];
                    //NSLog(@"****%@",[t substringWithRange:NSMakeRange([stringScanner scanLocation], 20)]);
                    
                    foundInteger = change_endian(foundInteger);
                    
                    [string appendString:[[NSString alloc] initWithData:[[NSData alloc] initWithBytes:&foundInteger length:2] encoding:NSUTF16StringEncoding]];
                }
                else
                {
                    [[NSException exceptionWithName:@"WrongUnicode" reason:@"Expected two bytes for the unicode." userInfo:nil] raise];
                }
                
            }
            else if([string2 hasPrefix:@"\\."])
            {
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+2];
                
                StringFound1 = [stringScanner scanUpToCharactersFromSet:hexadecimal intoString:&string1];
                if(StringFound1 && [string1 length]>=2)
                {
                    scanner = [scanner initWithString:[string1 substringToIndex:2]];
                    [scanner scanHexInt:&foundInteger];
                    [string appendString:[NSString stringWithFormat:@"%c",(char)foundInteger]];
                    [stringScanner setScanLocation:[stringScanner scanLocation]-[string1 length]+2];
                }
                else
                {
                    [[NSException exceptionWithName:@"WrongUnicode" reason:@"Expected one bytes for the unicode." userInfo:nil] raise];
                }
                
            }
            else if([string2 hasPrefix:@"\\["])
            {
                [stringScanner setScanLocation:[stringScanner scanLocation]-[string2 length]+2];
                
                if([stringScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"]"] intoString:&string1])
                {
                    [stringScanner setScanLocation:[stringScanner scanLocation]+1];
                    
                    string2 = MathematicaCommands[string1];
                    if(string2)
                    {
                        [string appendString:string2];
                    }
                    else
                    {
                        *missingCommand  = [NSString stringWithFormat:@"Not able to interpret the Mathematica command: \\[%@].",string1];
                    }
                }
            }
            else
            {
                [string appendString:string2];
            }
        }
        
    }
    
    if(numberOfQuotes<2)
    {
        [[NSException exceptionWithName:@"UnbalancedQuotes" reason:@"Unbalanced number of quotation marks." userInfo:nil] raise];
    }
    
    return string;
}

NSMutableArray* get_recent_documents(void) __attribute__((ns_returns_retained))
{
    hexadecimal = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"] invertedSet];
    
    NSString* init_file = [NSString stringWithContentsOfFile:[RecentDocumentsFile stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray* RecentDocuments = [[NSMutableArray alloc] init];
    
    NSString* missingCommand;
    
    //    NSString *plistPath = [@"/Users/andrea/Desktop" stringByAppendingPathComponent:@"myPlistFile.plist"];
    //    if (![[NSFileManager defaultManager] fileExistsAtPath: plistPath])
    //    {
    //        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"myPlistFile" ofType:@"plist"];
    //        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath:plistPath error:&error];
    //    }
    //    [[[NSDictionary alloc] initWithDictionary:@{@"MathematicaCommands":MathematicaCommands}] writeToFile:plistPath atomically: YES];

    //    MathematicaCommands = @{@"SZ":@"ß", @"LessEqual":@"≤", @"GreaterEqual":@"≥", @"Dash":@"–", @"LongDash":@"—", @"IHat":@"î",
    //                            @"Alpha":@"α", @"Micro":@"µ", @"CapitalOmega":@"Ω", @"Theta":@"θ", @"CapitalPhi":@"Φ",
    //                            @"CurlyPhi":@"φ",@"CapitalGamma":@"Γ",
    //                            @"Mu":@"μ",@"CurlyKappa":@"ϰ",@"Phi":@"ϕ",@"Chi":@"χ",@"Psi":@"ψ",@"Omega":@"ω",@"Tau":@"τ",@"Sigma":@"σ",
    //                            @"Rho":@"ρ",@"Pi":@"π",@"Omicron":@"ο",@"Xi":@"ξ",@"Nu":@"ν",@"CurlyEpsilon":@"ε",@"Zeta":@"ζ",@"Delta":@"δ",
    //                            @"CapitalLambda":@"Λ",@"CapitalDelta":@"Δ",@"CapitalSigma":@"Σ",@"ScriptCapitalL":@"ℒ",@"Bullet":@"•",
    //                            @"Congruent":@"≡",@"FilledCircle":@"●", @"RightArrow":@"→", @"LeftArrow":@"←",@"PlusMinus":@"±",@"Times":@"×",
    //                            @"Del":@"∇",@"FilledSquare":@"■",@"Lambda":@"λ",@"Kappa":@"κ",@"Iota":@"ι",@"Eta":@"η",@"Gamma":@"γ",@"Beta":@"β"};

    // [[[NSDictionary alloc] initWithDictionary:@{@"MathematicaCommands":MathematicaCommands}] writeToFile:test atomically: YES];

    // MathematicaCommands = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"../Resources/GetRecentMathematicaDocuments" ofType:@"plist"]][@"MathematicaCommands"];
    
    MathematicaCommands = [NSDictionary dictionaryWithDictionary:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"MathematicaCommands"]];

    //    if([@"ΩθΦΛΔΣαβγ𝛤Γδεζηικλτσρποξνμϰφϕχψωħ■∇℃⟩⟨×±≠≡Åℒ•.nb" isEqualToString:@"ΩθΦΛΔΣαβγ𝛤Γδεζηικλτσρποξνμϰφϕχψωħ■∇℃⟩⟨×±≠≡Åℒ•.nb"])
    //    {
    //        printf("Equal\n");
    //    }
    
    if( init_file )
    {
        NSScanner *stringScanner = [[NSScanner alloc] initWithString:init_file];
        [stringScanner setCharactersToBeSkipped: nil];
        
        NSString *StringFound;
        bool isStringFound;
        
        NSString* searchStr;
        
        NSString* basename;
        NSString* filename;
        NSMutableArray* basename_arr;
        

//        stringScanner = [stringScanner initWithString:@"dbidbc cufcfiu d  d \"Ma\\:030a          a\\:0308\\[LessEqual]ti[s-s>e@P\\owi\\:0302e\\[Dash]r\\\\Analy\\[LongDash]sis.nb\" dhodhc cfo fuhf"];
//        [stringScanner setCharactersToBeSkipped:nil];
//        ReadMathematicaString(stringScanner);
//        exit(0);
        
        searchStr = @"NotebooksMenu->{";
        [stringScanner scanUpToString:searchStr intoString:nil];
        
        if([stringScanner isAtEnd]==NO)
        {
            [stringScanner setScanLocation:[stringScanner scanLocation]+[searchStr length]];
            
            //NSLog(@"Len: %@ - Position: %@",@([searchStr length]),@([stringScanner scanLocation]));
            //NSLog(@"%@",[init_file substringWithRange:NSMakeRange([stringScanner scanLocation], 20)]);
            
            // [stringScanner scanUpToCharactersFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] intoString:nil];
            
            // NSLog(@"****%@",[init_file substringWithRange:NSMakeRange([stringScanner scanLocation], 20)]);
            
            int counter = 0;
            while([stringScanner isAtEnd]==NO /*&& counter < 100*/)
            {
                
                searchStr = @"FileName[{";
                [stringScanner scanUpToString:searchStr intoString:nil];
                
                if([stringScanner isAtEnd]==NO)
                {
                    [stringScanner setScanLocation:[stringScanner scanLocation]+[searchStr length]];
                    
                    basename_arr = [[NSMutableArray alloc] init];
                    
                    isStringFound = [stringScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@",}"] intoString:&StringFound];
                    
                    if( isStringFound )
                    {
                        [basename_arr addObject:[StringFound stringByReplacingOccurrencesOfString:@"$RootDirectory" withString:@""]];
                        
                        
                        //NSLog(@"Position: *****%@",[init_file substringWithRange:NSMakeRange([stringScanner scanLocation], 20)]);
                        
                        while([stringScanner isAtEnd]==NO && [init_file characterAtIndex:[stringScanner scanLocation]] != '}')
                        {
                            [basename_arr addObject:ReadMathematicaString(stringScanner,&missingCommand)];
                            [stringScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@",}"] intoString:nil];
                        }
                        
                        basename = [basename_arr componentsJoinedByString:@"/"];
                        filename = ReadMathematicaString(stringScanner,&missingCommand);
                        
                        //printf("%s\n",[[NSString stringWithFormat:@"%@/%@", basename, filename] fileSystemRepresentation]);
                        if(missingCommand)
                        {
                            [RecentDocuments addObject:@[missingCommand, @"Error in parsing Mathematica \"init.m\" file.",@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns"]];
                            counter++;
                        }
                        else
                        {
                            if( access([[NSString stringWithFormat:@"%@/%@", basename, filename] fileSystemRepresentation], F_OK ) != -1 )
                            {
                                [RecentDocuments addObject:@[basename, filename, @""]];
                                counter++;
                            } else {
                                // printf("%s\n",[[NSString stringWithFormat:@"%@/%@", basename, filename] fileSystemRepresentation]);
                            }
                        }
                    }
                }
                
                // [stringScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@",}"] intoString:nil];
            }
            
            // NSLog(@"Position: *****%@",[init_file substringWithRange:NSMakeRange([stringScanner scanLocation], 20)]);
        }
    }
    //exit(1);
    
    return RecentDocuments;
}

const char* create_LB_menu_entries(void)
{
    NSArray* RecentDocuments = get_recent_documents();
    
    // NSFileManager *fm = [NSFileManager defaultManager];
    if ([RecentDocuments count] > 0)
    {
        
        NSArray* LBkeys = @[@"title", @"subtitle", @"path", @"icon"];
        
        NSMutableArray* LBitems = [[NSMutableArray alloc] init];
        
        NSString* title;
        NSString* subtitle;
        NSString* icon;
        
        for(NSArray* filepath in [RecentDocuments reverseObjectEnumerator])
        {
            subtitle = filepath[0];
            title = filepath[1];
            icon = filepath[2];
            [LBitems addObject:[[NSDictionary alloc] initWithObjects:
                                @[title,
                                  subtitle,
                                  [NSString stringWithFormat:@"%@/%@", subtitle, title],
                                  icon
                                  //, [NSString stringWithFormat:@"%@:%@",APP_NAME,[icon lowercaseString]]
                                  ] forKeys:LBkeys]];
            
        }
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:LBitems
                                                           options:NSJSONWritingPrettyPrinted error:nil];
        
        return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] UTF8String];
    }
    else
    {
        return "";
    }
}

int main(int argc, const char * argv[]) {
    // @autoreleasepool {
    
    @try {
        //create_LB_menu_entries();
        fprintf(stdout, "%s", create_LB_menu_entries());
        
        return 0;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        
        return -1;
    }
    
    // }
    return 0;
}

