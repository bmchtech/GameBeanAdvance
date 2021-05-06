
enum Savetype {
    EEPROM_4k,
    EEPROM_4k_alt,
    EEPROM_8k,
    EEPROM_8k_alt,
    Flash_512k_Atmel_RTC
    Flash_512k_Atmel,
    Flash_512k_SST_RTC,
    Flash_512k_SST,
    Flash_512k_Panasonic_RTC,
    Flash_512k_Panasonic,
    Flash_1M_Macronix_RTC,
    Flash_1M_Macronix,
    Flash_1M_Sanyo_RTC,
    Flash_1M_Sanyo,
    SRAM_256K,
    NONE
}

Savetype get_savetype_from_ROM(ubyte[] rom) {
    string game_code = cast(char[]) rom[0xAC..0xAF];

    Savetype* savetype;

    savetype = (game_code in savetype_lookup_table);
    if (savetype !is null) {
        return *savetype;
    } else {
        return null;
    }
}

Savetype[string] savetype_lookup_table = [
    "BJB": Savetype.EEPROM_4k               , // EEPROM_V122     007 - Everything or Nothing
    "BFB": Savetype.SRAM_256K               , // SRAM_V113       2 Disney Games - Disney Sports Skateboarding + Football
    "BLQ": Savetype.EEPROM_4k               , // EEPROM_V124     2 Disney Games - Lilo & Stitch 2 + Peter Pan
    "BQJ": Savetype.NONE                    , // NONE            2 Game Pack - Hot Wheels Stunt Track + World Race
    "BB4": Savetype.NONE                    , // NONE            2 Game Pack! - Matchbox Missions
    "BUQ": Savetype.NONE                    , // NONE            2 Game Pack! Uno + Skip-Bo
    "BX6": Savetype.NONE                    , // NONE            2 Games in 1 - Battle for Bikini Bottom + Breakin' Da Rules
    "BU2": Savetype.EEPROM_4k               , // EEPROM_V124     2 Games in 1 - Battle for Bikini Bottom + Nicktoons Freeze Frame Frenzy
    "BL5": Savetype.NONE                    , // NONE            2 Games in 1 - Bionicle + Knights' Kingdom
    "BWB": Savetype.EEPROM_4k               , // EEPROM_V122     2 Games in 1 - Brother Bear + Disney Princess
    "BLB": Savetype.EEPROM_4k               , // EEPROM_V122     2 Games in 1 - Brother Bear + The Lion King
    "BW2": Savetype.NONE                    , // NONE            2 Games in 1 - Cartoon Network - Block Party + Speedway
    "BW9": Savetype.Flash_512k_Panasonic    , // FLASH_V133      2 Games in 1 - Columns Crown + ChuChu Rocket!
    "BLP": Savetype.EEPROM_4k               , // EEPROM_V124     2 Games in 1 - Disney Princess + The Lion King
    "B2E": Savetype.NONE                    , // NONE            2 Games in 1 - Dora the Explorer - Pirate Pig's Treasure + Super Star Adventures
    "BZP": Savetype.EEPROM_4k               , // EEPROM_V124     2 Games in 1 - Dr. Mario + Puzzle League
    "BUF": Savetype.EEPROM_4k_alt           , // EEPROM_V124     2 Games in 1 - Dragon Ball Z - Buu's Fury + Dragon Ball GT - Transformation
    "BFW": Savetype.NONE                    , // NONE            2 Games in 1 - Finding Nemo + Finding Nemo - The Continuing Adventures
    "BDZ": Savetype.NONE                    , // NONE            2 Games in 1 - Finding Nemo + Monsters, Inc.
    "BIN": Savetype.NONE                    , // NONE            2 Games in 1 - Finding Nemo + The Incredibles
    "BWC": Savetype.NONE                    , // NONE            2 Games in 1 - Golden Nugget Casino - Texas Hold'em Poker
    "BHZ": Savetype.NONE                    , // NONE            2 Games in 1 - Hot Wheels - World Race + Velocity X
    "BLD": Savetype.EEPROM_4k_alt           , // EEPROM_V124     2 Games in 1 - Lizzie McGuire - Disney Princess
    "BAR": Savetype.EEPROM_4k               , // EEPROM_V122     2 Games in 1 - Moto GP - GT 3 Advance
    "BRZ": Savetype.NONE                    , // NONE            2 Games in 1 - Power Rangers Time Force + Ninja Storm
    "BWQ": Savetype.NONE                    , // NONE            2 Games in 1 - Quad Desert Fury + Monster Trucks
    "BPU": Savetype.EEPROM_4k               , // EEPROM_V124     2 Games in 1 - Scooby-Doo + Scooby-Doo 2
    "BCV": Savetype.EEPROM_4k               , // EEPROM_V122     2 Games in 1 - Scooby-Doo and the Cyber Chase + Mystery Mayhem
    "BW3": Savetype.Flash_512k_Panasonic    , // FLASH_V133      2 Games in 1 - Sonic Advance + Chu Chu Rocket
    "BW7": Savetype.Flash_512k_Panasonic    , // FLASH_V133      2 Games in 1 - Sonic Battle + ChuChu Rocket!
    "BW4": Savetype.Flash_512k_Panasonic    , // FLASH_V133      2 Games in 1 - Sonic Battle + Sonic Advance
    "BW8": Savetype.Flash_512k_Panasonic    , // FLASH_V133      2 Games in 1 - Sonic Pinball + Columns Crown
    "BW6": Savetype.Flash_512k_Panasonic    , // FLASH_V133      2 Games in 1 - Sonic Pinball Party + Sonic Battle
    "BSZ": Savetype.NONE                    , // NONE            2 Games in 1 - SpongeBob SquarePants - Supersponge + Battle for Bikini Bottom
    "BDF": Savetype.NONE                    , // NONE            2 Games in 1 - SpongeBob SquarePants - Supersponge + Revenge of the Flying Dutchman
    "BRS": Savetype.NONE                    , // NONE            2 Games in 1 - SpongeBob SquarePants - Supersponge + Rugrats - Go Wild
    "BBJ": Savetype.NONE                    , // NONE            2 Games in 1 - SpongeBob SquarePants + Jimmy Neutron
    "BNE": Savetype.NONE                    , // NONE            2 Games in 1 - The Incredibles + Finding Nemo - The Continuing Adventure
    "B2B": Savetype.EEPROM_4k               , // EEPROM_V124     2 Games in 1 - The SpongeBob SquarePants Movie + Freeze Frame Frenzy
    "B2A": Savetype.EEPROM_4k               , // EEPROM_V124     2 in 1 - Asterix & Obelix - PAF! Them All! + XXL
    "BLF": Savetype.EEPROM_4k_alt           , // EEPROM_V124     2 in 1 - Dragon Ball Z 1 and 2
    "B94": Savetype.EEPROM_8k               , // EEPROM_V124     2 in 1 - Pferd & Pony - Mein Pferdehof + Lass Uns Reiten 2
    "BX2": Savetype.EEPROM_4k               , // EEPROM_V124     2 in 1 - Spider-Man Mysterio's Menace & X2 Wolverine's Revenge
    "BX4": Savetype.EEPROM_4k_alt           , // EEPROM_V122     2 in 1 - Tony Hawk's Underground + Kelly Slater's Pro Surfer
    "BCS": Savetype.EEPROM_4k_alt           , // EEPROM_V124     2 in 1 - V-Rally 3 - Stuntman
    "BXH": Savetype.EEPROM_4k               , // EEPROM_V124     2 in 1 Fun Pack - Madagascar - Operation Penguin + Shrek 2
    "BXG": Savetype.EEPROM_4k               , // EEPROM_V124     2 in 1 Fun Pack - Madagascar + Shrek 2
    "BS7": Savetype.EEPROM_4k               , // EEPROM_V124     2 in 1 Game Pack - Shark Tale + Shrek 2
    "BX3": Savetype.EEPROM_4k_alt           , // EEPROM_V125     2 in 1 GamePack - Spider-Man + Spider-Man 2
    "BT5": Savetype.NONE                    , // NONE            2 Jeux en 1 - Titeuf - Ze Gag Machine + Mega Compet
    "BC4": Savetype.NONE                    , // NONE            3 Game Pack - Candy Land + Chutes and Ladders + Memory
    "B3O": Savetype.NONE                    , // NONE            3 Game Pack - Mouse Trap + Simon + Operation
    "B3U": Savetype.NONE                    , // NONE            3 Game Pack - The Game of Life + Yahtzee + Payday
    "BXC": Savetype.NONE                    , // NONE            3 Game Pack! - Ker Plunk! + Toss Across + Tip It
    "B44": Savetype.EEPROM_4k               , // EEPROM_V122     3 Games in 1 - Rugrats, SpongeBob, Tak
    "BRQ": Savetype.NONE                    , // NONE            3 Games in One - Majesco's Rec Room Challenge
    "B3N": Savetype.NONE                    , // NONE            3 Games in One - Majesco's Sports Pack
    "BI4": Savetype.SRAM_256K               , // SRAM_V113       4 Games on One Game Pak - GT Advance - GT Advance 2 - GT Advance 3 - Moto GP
    "BI7": Savetype.SRAM_256K               , // SRAM_V113       4 Games on One Game Pak - Nickelodeon
    "BI6": Savetype.SRAM_256K               , // SRAM_V113       4 Games on One Game Pak (Nickelodeon Movies)
    "A3Q": Savetype.NONE                    , // NONE            A Sound of Thunder
    "BAE": Savetype.NONE                    , // NONE            Ace Combat Advance
    "ALX": Savetype.EEPROM_4k               , // EEPROM_V122     Ace Lightning
    "BAC": Savetype.NONE                    , // NONE            Action Man - Robot Atak
    "BAV": Savetype.EEPROM_4k               , // EEPROM_V122     Activision Anthology
    "AG7": Savetype.SRAM_256K               , // SRAM_V110       Advance GTA
    "BGC": Savetype.EEPROM_4k               , // EEPROM_V124     Advance Guardian Heroes
    "BAG": Savetype.EEPROM_4k               , // EEPROM_V124     Advance Guardian Heroes
    "AR7": Savetype.SRAM_256K               , // SRAM_V112       Advance Rally
    "AWR": Savetype.Flash_512k_Atmel        , // FLASH_V121      Advance Wars
    "AW2": Savetype.Flash_512k_SST          , // FLASH_V126      Advance Wars 2 - Black Hole Rising
    "ADE": Savetype.SRAM_256K               , // SRAM_V112       Adventure of Tokyo Disney Sea
    "AAO": Savetype.EEPROM_4k               , // EEPROM_V122     Aero the Acro-Bat - Rascal Rival Revenge
    "ACE": Savetype.NONE                    , // NONE            Agassi Tennis Generation
    "BHQ": Savetype.NONE                    , // NONE            Agent Hugo - Roborumble
    "AIL": Savetype.NONE                    , // NONE            Aggressive Inline
    "AAK": Savetype.EEPROM_4k               , // EEPROM_V122     Air Force Delta Storm
    "BAZ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Akachan Doubutsu Sono
    "BZW": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Akagi
    "BAD": Savetype.EEPROM_4k               , // EEPROM_V122     Aladdin
    "AJ6": Savetype.EEPROM_4k               , // EEPROM_V122     Aladdin
    "BAB": Savetype.EEPROM_4k               , // EEPROM_V124     Aleck Bordon Adventure - Tower & Shaft Advance
    "ATF": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Alex Ferguson's Player Manager 2002
    "BAW": Savetype.EEPROM_4k               , // EEPROM_V124     Alex Rider - Stormbreaker
    "BAH": Savetype.EEPROM_4k               , // EEPROM_V124     Alien Hominid
    "AEV": Savetype.NONE                    , // NONE            Alienators - Evolution Continues
    "BAL": Savetype.EEPROM_4k               , // EEPROM_V124     All Grown Up - Express Yourself
    "AA3": Savetype.SRAM_256K               , // SRAM_V112       All-Star Baseball 2003
    "AA7": Savetype.SRAM_256K               , // SRAM_V113       All-Star Baseball 2004
    "AAR": Savetype.EEPROM_4k               , // EEPROM_V122     Altered Beast - Guardian of the Realms
    "AAB": Savetype.EEPROM_4k_alt           , // EEPROM_V122     American Bass Challenge
    "BAP": Savetype.EEPROM_4k               , // EEPROM_V124     American Dragon - Jake Long
    "BID": Savetype.NONE                    , // NONE            American Idol
    "AFG": Savetype.NONE                    , // NONE            An American Tail - Fievel's Gold Rush
    "AFN": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Angel Collection - Mezase! Gakuen no Fashion Leader
    "BEC": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Angel Collection 2 - Pichimo ni Narou
    "AAG": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Angelique
    "AAN": Savetype.SRAM_256K               , // SRAM_V102       Animal Mania - DokiDoki Aishou Check
    "AAQ": Savetype.NONE                    , // NONE            Animal Snap - Rescue Them 2 By 2
    "BAY": Savetype.SRAM_256K               , // SRAM_V113       Animal Yokochou - Doki Doki Kyushutsu Daisakusen No Maki
    "BAX": Savetype.SRAM_256K               , // SRAM_V103       Animal Yokochou - Doki Doki Shinkyuu Shiken! no Kan
    "ANI": Savetype.NONE                    , // NONE            Animaniacs - Lights, Camera, Action!
    "ANU": Savetype.NONE                    , // NONE            Antz - Extreme Racing
    "ANZ": Savetype.NONE                    , // NONE            Antz - Extreme Racing
    "AAZ": Savetype.EEPROM_4k               , // EEPROM_V122     Ao-Zoura to Nakamatachi - Yume no Bouken
    "BPL": Savetype.NONE                    , // NONE            Archer Maclean's 3D Pool
    "AZN": Savetype.NONE                    , // NONE            Archer Maclean's Super Dropzone
    "BB5": Savetype.NONE                    , // NONE            Arctic Tale
    "AME": Savetype.NONE                    , // NONE            Army Men - Operation Green
    "AY3": Savetype.EEPROM_4k               , // EEPROM_V121     Army Men - Turf Wars
    "ASA": Savetype.NONE                    , // NONE            Army Men Advance
    "B8D": Savetype.NONE                    , // NONE            Around the World in 80 Days
    "B2N": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Arthur and the Invisibles
    "BAM": Savetype.SRAM_256K               , // SRAM_V113       Ashita no Joe - Makka ni Moeagare!
    "AOB": Savetype.NONE                    , // NONE            Asterix & Obelix - Bash Them All!
    "BLX": Savetype.EEPROM_4k               , // EEPROM_V124     Asterix & Obelix - XXL
    "BTA": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Astro Boy - Omega Factor
    "AAV": Savetype.NONE                    , // NONE            Atari Anniversary Advance
    "ATL": Savetype.NONE                    , // NONE            Atlantis - The Lost Empire
    "BET": Savetype.NONE                    , // NONE            Atomic Betty
    "AQR": Savetype.NONE                    , // NONE            ATV Quad Power Racing
    "B3B": Savetype.NONE                    , // NONE            ATV Thunder - Ridge Riders
    "BQZ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Avatar - The Last Airbender
    "BBW": Savetype.NONE                    , // NONE            Avatar - The Last Airbender - The Burning Earth
    "AZA": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Azumanga Daiou Advance
    "BBV": Savetype.EEPROM_4k               , // EEPROM_V124     Babar - To the Rescue
    "BBC": Savetype.NONE                    , // NONE            Back to Stone
    "ABK": Savetype.EEPROM_4k               , // EEPROM_V122     BackTrack
    "ACK": Savetype.EEPROM_4k               , // EEPROM_V122     Backyard Baseball
    "BCY": Savetype.EEPROM_4k               , // EEPROM_V124     Backyard Baseball 2006
    "AYB": Savetype.EEPROM_4k               , // EEPROM_V124     Backyard Basketball
    "AYF": Savetype.EEPROM_4k               , // EEPROM_V122     Backyard Football
    "BYH": Savetype.EEPROM_4k               , // EEPROM_V122     Backyard Hockey
    "BYF": Savetype.EEPROM_4k               , // EEPROM_V124     Backyard NFL Football 2006
    "BS6": Savetype.EEPROM_4k               , // EEPROM_V124     Backyard Skateboarding
    "BC7": Savetype.EEPROM_4k               , // EEPROM_V124     Backyard Sports - Baseball 2007
    "BB7": Savetype.EEPROM_4k               , // EEPROM_V124     Backyard Sports - Basketball 2007
    "BF7": Savetype.EEPROM_4k               , // EEPROM_V124     Backyard Sports - Football 2007
    "AHE": Savetype.SRAM_256K               , // SRAM_V112       Bakuten Shoot Beyblade - Gekitou! Saikyou Blader
    "AB8": Savetype.SRAM_256K               , // SRAM_V112       Bakuten Shoot Beyblade 2002 - Ikuze! Bakutou! Chou Jiryoku Battle!!
    "A3E": Savetype.SRAM_256K               , // SRAM_V112       Bakuten Shoot Beyblade 2002 - Team Battle!! Daichi Hen
    "A3W": Savetype.SRAM_256K               , // SRAM_V112       Bakuten Shoot Beyblade 2002 - Team Battle!! Takao Hen
    "BGD": Savetype.EEPROM_4k               , // EEPROM_V124     Baldurs Gate - Dark Alliance
    "AEE": Savetype.NONE                    , // NONE            Ballistic - Ecks vs Sever
    "BAJ": Savetype.EEPROM_4k               , // EEPROM_V124     Banjo Pilot
    "BKZ": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Banjo-Kazooie - Grunty's Revenge
    "BAU": Savetype.NONE                    , // NONE            Barbie - The Princess and the Pauper
    "BE5": Savetype.NONE                    , // NONE            Barbie and the Magic of Pegasus
    "BBN": Savetype.EEPROM_4k               , // EEPROM_V124     Barbie as the Island Princess
    "AVB": Savetype.NONE                    , // NONE            Barbie Groovy Games
    "AI8": Savetype.NONE                    , // NONE            Barbie Horse Adventures - Blue Ribbon Race
    "BB3": Savetype.NONE                    , // NONE            Barbie in the 12 Dancing Princesses
    "BBE": Savetype.NONE                    , // NONE            Barbie Superpack - Secret Agent + Groovy Games
    "BBY": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Barnyard
    "ABP": Savetype.SRAM_256K               , // SRAM_V102       Baseball Advance
    "AZB": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Bass Tsuri Shiyouze!
    "BBG": Savetype.EEPROM_4k               , // EEPROM_V124     Batman Begins
    "BAT": Savetype.NONE                    , // NONE            Batman Rise of Sin Tzu
    "ABT": Savetype.NONE                    , // NONE            Batman Vengeance
    "BDX": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Battle B-Daman
    "BBM": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Battle B-Daman - Fire Spirits
    "BBF": Savetype.EEPROM_4k               , // EEPROM_V122     Battle x Battle - Kyoudai Ou Densetsu
    "ABE": Savetype.EEPROM_4k               , // EEPROM_V120     BattleBots - Beyond the BattleBox
    "BBD": Savetype.NONE                    , // NONE            BattleBots - Design & Destroy
    "A8L": Savetype.SRAM_256K               , // SRAM_V103       BB Ball
    "AH5": Savetype.SRAM_256K               , // SRAM_V102       Beast Shooter - Mezase Beast King!
    "BHB": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Best Friends - Dogs & Cats
    "A8Y": Savetype.Flash_512k_SST          , // FLASH_V126      Best Play Pro Yakyuu
    "BB2": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Beyblade G-Revolution
    "BEY": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Beyblade VForce - Ultimate Blader Jam
    "BBX": Savetype.NONE                    , // NONE            Bibi Blocksberg - Der Magische Hexenkreis
    "BUX": Savetype.EEPROM_4k               , // EEPROM_V124     Bibi und Tina - Ferien auf dem Martinshof
    "BIB": Savetype.NONE                    , // NONE            Bible Game, The
    "B63": Savetype.EEPROM_4k               , // EEPROM_V124     Big Mutha Truckers
    "BIO": Savetype.NONE                    , // NONE            Bionicle
    "A5A": Savetype.EEPROM_4k               , // EEPROM_V120     Bionicle - Matoran Adventures
    "BIL": Savetype.EEPROM_4k               , // EEPROM_V124     Bionicle - Maze of Shadows
    "BIH": Savetype.EEPROM_4k               , // EEPROM_V124     Bionicle Heroes
    "BVD": Savetype.SRAM_256K               , // SRAM_V113       bit Generations - Boundish
    "BVA": Savetype.SRAM_256K               , // SRAM_V113       bit Generations - Coloris
    "BVB": Savetype.SRAM_256K               , // SRAM_V113       bit Generations - Dial Hex
    "BVH": Savetype.SRAM_256K               , // SRAM_V103       bit Generations - Digidrive
    "BVC": Savetype.SRAM_256K               , // SRAM_V113       bit Generations - Dotstream
    "BVE": Savetype.SRAM_256K               , // SRAM_V113       bit Generations - Orbital
    "BVG": Savetype.SRAM_256K               , // SRAM_V113       bit Generations - Soundvoyager
    "AB6": Savetype.EEPROM_4k               , // EEPROM_V120     Black Belt Challenge
    "AWE": Savetype.SRAM_256K               , // SRAM_V112       Black Black - Bura Bura
    "AXB": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Black Matrix Zero
    "AQX": Savetype.EEPROM_4k               , // EEPROM_V122     Blackthorne
    "BBH": Savetype.NONE                    , // NONE            Blades of Thunder
    "BLE": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Bleach Advance
    "ABR": Savetype.SRAM_256K               , // SRAM_V112       Blender Bros.
    "AT9": Savetype.EEPROM_4k               , // EEPROM_V122     BMX Trick Racer
    "B6E": Savetype.NONE                    , // NONE            Board Games Classics
    "BB9": Savetype.SRAM_256K               , // SRAM_V113       Boboboubo Boubobo - 9 Kiwame Senshi Gyagu Yuugou
    "BOB": Savetype.SRAM_256K               , // SRAM_V103       Boboboubo Boubobo - Maji De!! Shinken Battle
    "A8V": Savetype.SRAM_256K               , // SRAM_V112       Boboboubo Boubobo - Ougi 87.5 Bakuretsu Hanage Shinken
    "BOS": Savetype.SRAM_256K               , // SRAM_V113       Boboboubo Boubobo Bakutou Hajike Taisen
    "U3I": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Boktai - The Sun is in Your Hand
    "U32": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Boktai 2 - Solar Boy Django
    "ABC": Savetype.SRAM_256K               , // SRAM_V110       Boku ha Koukuu Kanseikan
    "AJZ": Savetype.SRAM_256K               , // SRAM_V112       Bomberman Jetters
    "BOM": Savetype.EEPROM_4k               , // EEPROM_V122     Bomberman Jetters - Game Collection
    "AMH": Savetype.EEPROM_4k_alt           , // EEPROM_V121     Bomberman Max 2 - Blue Advance
    "AMY": Savetype.EEPROM_4k_alt           , // EEPROM_V121     Bomberman Max 2 - Red Advance
    "ABS": Savetype.SRAM_256K               , // SRAM_V112       Bomberman Tournament
    "BKW": Savetype.EEPROM_4k               , // EEPROM_V122     Bookworm
    "BPD": Savetype.SRAM_256K               , // SRAM_V113       Bouken Yuuki PlaStar World - Densetsu no PlaStar Gate EX
    "APJ": Savetype.SRAM_256K               , // SRAM_V113       Bouken Yuuki Pluster World - Densetsu no PlustoGate
    "A2P": Savetype.SRAM_256K               , // SRAM_V112       Bouken Yuuki Pluster World - Pluston GP
    "BOV": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Bouken-Ou Beet - Busters Road
    "BBS": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Boukyaku no Senritsu
    "ABD": Savetype.EEPROM_4k               , // EEPROM_V122     Boulder Dash EX
    "ABO": Savetype.NONE                    , // NONE            Boxing Fever
    "A2R": Savetype.EEPROM_4k               , // EEPROM_V122     Bratz
    "BBZ": Savetype.NONE                    , // NONE            Bratz - Babyz
    "BXF": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Bratz - Forever Diamondz
    "BRR": Savetype.EEPROM_4k               , // EEPROM_V124     Bratz - Rock Angelz
    "BBU": Savetype.NONE                    , // NONE            Bratz - The Movie
    "B6Z": Savetype.NONE                    , // NONE            Breakout + Centipede + Warlords
    "ABF": Savetype.SRAM_256K               , // SRAM_V112       Breath of Fire
    "AB2": Savetype.SRAM_256K               , // SRAM_V112       Breath of Fire II
    "ABY": Savetype.NONE                    , // NONE            Britney's Dance Beat
    "ABJ": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Broken Sword - The Shadow of the Templars
    "BBR": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Brother Bear
    "ALE": Savetype.EEPROM_4k               , // EEPROM_V122     Bruce Lee - Return of the Legend
    "AON": Savetype.EEPROM_4k               , // EEPROM_V122     Bubble Bobble - Old & New
    "A2B": Savetype.EEPROM_4k               , // EEPROM_V122     Bubble Bobble - Old & New
    "AVY": Savetype.EEPROM_4k               , // EEPROM_V122     Buffy - Im Bann der Daemonen
    "ABW": Savetype.NONE                    , // NONE            Butt-Ugly Martians - B.K.M. Battles
    "AUQ": Savetype.NONE                    , // NONE            Butt-Ugly Martians - B.K.M. Battles
    "BCG": Savetype.EEPROM_4k               , // EEPROM_V124     Cabbage Patch Kids - The Patch Puppy Rescue
    "A8H": Savetype.NONE                    , // NONE            Cabela's Big Game Hunter
    "BG5": Savetype.EEPROM_4k               , // EEPROM_V124     Cabela's Big Game Hunter - 2005 Adventures
    "ACP": Savetype.NONE                    , // NONE            Caesars Palace Advance
    "BIX": Savetype.Flash_1M_Macronix       , // FLASH_V102      Calciobit
    "BLC": Savetype.EEPROM_4k               , // EEPROM_V124     Camp Lazlo - Leaky Lake Games
    "BC6": Savetype.NONE                    , // NONE            Capcom Classics - Mini Mix
    "AKY": Savetype.SRAM_256K               , // SRAM_V112       Captain Tsubasa - Eikou no Kiseki
    "ACB": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Car Battler Joe
    "BK3": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Card Captor Sakura - Sakura Card de Mini Game
    "BKS": Savetype.EEPROM_4k               , // EEPROM_V124     Card Captor Sakura - Sakura to Card to Otomodachi
    "PEA": Savetype.Flash_512k_SST          , // FLASH_V124      Card E-Reader
    "A8C": Savetype.NONE                    , // NONE            Card Party
    "BEA": Savetype.EEPROM_4k               , // EEPROM_V124     Care Bears - The Care Quest
    "AED": Savetype.EEPROM_4k               , // EEPROM_V122     Carrera Power Slide
    "BCA": Savetype.EEPROM_4k               , // EEPROM_V124     Cars
    "BCP": Savetype.NONE                    , // NONE            Cars Mater-National Championship
    "AC9": Savetype.NONE                    , // NONE            Cartoon Network Block Party
    "ANR": Savetype.NONE                    , // NONE            Cartoon Network Speedway
    "ACS": Savetype.NONE                    , // NONE            Casper
    "A2C": Savetype.SRAM_256K               , // SRAM_V102       Castlevania - Aria of Sorrow
    "AAM": Savetype.SRAM_256K               , // SRAM_V110       Castlevania - Circle of the Moon
    "ACH": Savetype.SRAM_256K               , // SRAM_V102       Castlevania - Harmony of Dissonance
    "BXK": Savetype.SRAM_256K               , // SRAM_V102       Castlevania Double Pack
    "BCW": Savetype.EEPROM_4k               , // EEPROM_V120     Catwoman
    "AN3": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Catz
    "BCF": Savetype.EEPROM_4k               , // EEPROM_V124     Charlie and the Chocolate Factory
    "BCJ": Savetype.EEPROM_4k               , // EEPROM_V124     Charlotte's Web
    "ACY": Savetype.EEPROM_4k               , // EEPROM_V122     Chessmaster
    "BCH": Savetype.EEPROM_4k               , // EEPROM_V124     Chicken Little
    "B6F": Savetype.NONE                    , // NONE            Chicken Shoot
    "B6G": Savetype.NONE                    , // NONE            Chicken Shoot 2
    "AOC": Savetype.EEPROM_4k               , // EEPROM_V122     Chobits for GameBoy Advance
    "A5B": Savetype.SRAM_256K               , // SRAM_V112       Chocobo Land - A Game of Dice
    "ACJ": Savetype.EEPROM_4k               , // EEPROM_V122     Chou Makai-Mura R
    "ACR": Savetype.Flash_512k_Atmel        , // FLASH_V121      Chu Chu Rocket!
    "BCM": Savetype.EEPROM_4k_alt           , // EEPROM_V122     CIMA - The Enemy
    "BCD": Savetype.EEPROM_4k               , // EEPROM_V124     Cinderella - Magical Dreams
    "B2S": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Cinnamon - Yume no Daibouken
    "B43": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Cinnamon Fuwafuwa Daisakusen
    "BPS": Savetype.EEPROM_4k               , // EEPROM_V124     Cinnamoroll Kokoniiruyo
    "FBM": Savetype.EEPROM_4k               , // EEPROM_V124     Classic NES Series - Bomberman
    "FAD": Savetype.EEPROM_4k               , // EEPROM_V124     Classic NES Series - Castlevania
    "FDK": Savetype.EEPROM_4k               , // EEPROM_V122     Classic NES Series - Donkey Kong
    "FDM": Savetype.EEPROM_4k               , // EEPROM_V124     Classic NES Series - Dr. Mario
    "FEB": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Classic NES Series - ExciteBike
    "FIC": Savetype.EEPROM_4k               , // EEPROM_V122     Classic NES Series - Ice Climber
    "FMR": Savetype.EEPROM_4k               , // EEPROM_V124     Classic NES Series - Metroid
    "FP7": Savetype.EEPROM_4k               , // EEPROM_V122     Classic NES Series - Pac-Man
    "FSM": Savetype.EEPROM_4k               , // EEPROM_V124     Classic NES Series - Super Mario Bros.
    "FZL": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Classic NES Series - The Legend of Zelda
    "FXV": Savetype.EEPROM_4k               , // EEPROM_V122     Classic NES Series - Xevious
    "FLB": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Classic NES Series - Zelda II - The Adventure of Link
    "BC5": Savetype.NONE                    , // NONE            Cocoto - Kart Racer
    "BC8": Savetype.NONE                    , // NONE            Cocoto Platform Jumper
    "BND": Savetype.NONE                    , // NONE            Codename Kids Next Door - Operation S.O.D.A.
    "ACM": Savetype.EEPROM_4k               , // EEPROM_V122     Colin McRae Rally 2.0
    "ACG": Savetype.EEPROM_4k               , // EEPROM_V122     Columns Crown
    "AQC": Savetype.SRAM_256K               , // SRAM_V112       Combat Choro Q - Advance Daisakusen
    "BW5": Savetype.Flash_512k_Panasonic    , // FLASH_V133      Combo Pack - Sonic Advance + Sonic Pinball Party
    "ACZ": Savetype.EEPROM_4k               , // EEPROM_V122     Comix Zone
    "B65": Savetype.NONE                    , // NONE            Connect Four - Perfection - Trouble
    "AAW": Savetype.NONE                    , // NONE            Contra Advance - The Alien Wars EX
    "AVC": Savetype.EEPROM_4k               , // EEPROM_V122     Corvette
    "B5A": Savetype.EEPROM_4k               , // EEPROM_V122     Crash & Spyro - Super Pack Volume 1
    "B52": Savetype.EEPROM_4k               , // EEPROM_V122     Crash & Spyro - Super Pack Volume 2
    "B53": Savetype.EEPROM_4k_alt           , // EEPROM_V126     Crash & Spyro Superpack - Ripto's Rampage + The Cortex Conspiracy
    "B54": Savetype.EEPROM_4k               , // EEPROM_V122     Crash & Spyro Superpack - The Huge Adventure + Season of Ice
    "ACQ": Savetype.EEPROM_4k               , // EEPROM_V122     Crash Bandicoot - The Huge Adventure
    "AC8": Savetype.EEPROM_4k               , // EEPROM_V122     Crash Bandicoot 2 - N-Tranced
    "ACU": Savetype.EEPROM_4k               , // EEPROM_V122     Crash Bandicoot Advance
    "BKD": Savetype.EEPROM_4k               , // EEPROM_V124     Crash Bandicoot Advance - Wakuwaku Tomodachi Daisakusen
    "BD4": Savetype.EEPROM_4k               , // EEPROM_V124     Crash Bandicoot Purple - Ripto's Rampage
    "BCN": Savetype.EEPROM_4k               , // EEPROM_V122     Crash Nitro Kart
    "BQC": Savetype.EEPROM_4k               , // EEPROM_V124     Crash of the Titans
    "B8A": Savetype.EEPROM_8k               , // EEPROM_V122     Crash Superpack - N-Tranced + Nitro Kart
    "BC2": Savetype.EEPROM_8k               , // EEPROM_V126     Crayon Shin chan - Densetsu wo Yobu Omake no Miyako Shockgaan
    "BKC": Savetype.EEPROM_4k               , // EEPROM_V124     Crayon Shin-Chan - Arashi no Yobu Cinema-Land no Daibouken!
    "ACC": Savetype.EEPROM_4k               , // EEPROM_V122     Crazy Chase
    "BCR": Savetype.EEPROM_4k               , // EEPROM_V124     Crazy Frog Racer
    "A3C": Savetype.EEPROM_4k               , // EEPROM_V122     Crazy Taxi - Catch a Ride
    "ACT": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Creatures
    "A6C": Savetype.SRAM_256K               , // SRAM_V102       Croket! - Yume no Banker Survival!
    "BK2": Savetype.SRAM_256K               , // SRAM_V103       Croket! 2 - Yami no Bank to Banqueen
    "B3K": Savetype.SRAM_256K               , // SRAM_V103       Croket! 3 - Guranyuu Oukoku no Nazo
    "BK4": Savetype.SRAM_256K               , // SRAM_V103       Croket! 4 - Bank no Mori no Mamorigami
    "AQD": Savetype.NONE                    , // NONE            Crouching Tiger Hidden Dragon
    "ACF": Savetype.NONE                    , // NONE            Cruis'n Velocity
    "BCB": Savetype.EEPROM_4k               , // EEPROM_V124     Crushed Baseball
    "AC7": Savetype.NONE                    , // NONE            CT Special Forces
    "A9C": Savetype.NONE                    , // NONE            CT Special Forces 2 - Back in the Trenches
    "BC3": Savetype.NONE                    , // NONE            CT Special Forces 3 - Bioterror
    "ACX": Savetype.EEPROM_4k               , // EEPROM_V120     Cubix - Robots for Everyone - Clash 'N Bash
    "B3J": Savetype.NONE                    , // NONE            Curious George
    "ARJ": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Custom Robo GX
    "AZ3": Savetype.SRAM_256K               , // SRAM_V112       Cyberdrive Zoids - Kijuu no Senshi Hyuu
    "AHM": Savetype.EEPROM_4k               , // EEPROM_V122     Dai-Mahjong
    "ADS": Savetype.Flash_512k_SST          , // FLASH_V126      Daisenryaku for GameBoy Advance
    "ATD": Savetype.SRAM_256K               , // SRAM_V102       Daisuki Teddy
    "BDN": Savetype.SRAM_256K               , // SRAM_V113       Dan Doh!! - Tobase Shouri no Smile Shot!!
    "AXH": Savetype.SRAM_256K               , // SRAM_V112       Dan Doh!! Xi
    "A9S": Savetype.EEPROM_4k               , // EEPROM_V122     Dancing Sword - Senkou
    "BUE": Savetype.EEPROM_4k               , // EEPROM_V124     Danny Phantom - The Ultimate Enemy
    "BQY": Savetype.EEPROM_4k               , // EEPROM_V124     Danny Phantom - Urban Jungle
    "AVL": Savetype.NONE                    , // NONE            Daredevil
    "A2D": Savetype.EEPROM_4k               , // EEPROM_V122     Darius R
    "ADA": Savetype.NONE                    , // NONE            Dark Arena
    "AX2": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Dave Mirra Freestyle BMX 2
    "AB3": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Dave Mirra Freestyle BMX 3
    "ABQ": Savetype.EEPROM_4k               , // EEPROM_V122     David Beckham Soccer
    "AD6": Savetype.EEPROM_4k               , // EEPROM_V122     Davis Cup
    "BDE": Savetype.NONE                    , // NONE            Dead to Rights
    "BZN": Savetype.NONE                    , // NONE            Deal or No Deal
    "A2F": Savetype.EEPROM_4k               , // EEPROM_V122     Defender
    "ADH": Savetype.EEPROM_4k               , // EEPROM_V122     Defender of the Crown
    "AC5": Savetype.SRAM_256K               , // SRAM_V103       DemiKids - Dark Version
    "AL4": Savetype.SRAM_256K               , // SRAM_V103       DemiKids - Light Version
    "A9A": Savetype.NONE                    , // NONE            Demon Driver - Time to Burn Rubber!
    "ADB": Savetype.EEPROM_4k               , // EEPROM_V122     Denki Blocks!
    "AST": Savetype.SRAM_256K               , // SRAM_V112       Densetsu no Stafi
    "AVF": Savetype.SRAM_256K               , // SRAM_V113       Densetsu no Stafi 2
    "B3D": Savetype.SRAM_256K               , // SRAM_V113       Densetsu no Stafi 3
    "A8P": Savetype.Flash_512k_SST          , // FLASH_V126      Derby Stallion Advance
    "ADI": Savetype.NONE                    , // NONE            Desert Strike Advance
    "ADX": Savetype.NONE                    , // NONE            Dexter's Laboratory - Chess Challenge
    "ADL": Savetype.EEPROM_4k               , // EEPROM_V122     Dexter's Laboratory - Deesaster Strikes!
    "A3O": Savetype.SRAM_256K               , // SRAM_V102       Di Gi Charat - DigiCommunication
    "ADD": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Diadroids World - Evil Teikoku no Yabou
    "BXW": Savetype.EEPROM_4k               , // EEPROM_V124     Die Wilden Fussball Kerle - Gefahr im Wilde Kerle Land
    "BWU": Savetype.NONE                    , // NONE            Die wilden Fussballkerle - Entscheidung im Teufelstopf
    "BDK": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Digi Communication 2 in 1 Datou! Black Gemagema Dan
    "A8S": Savetype.EEPROM_4k               , // EEPROM_V122     Digimon - Battle Spirit
    "BDS": Savetype.EEPROM_4k               , // EEPROM_V122     Digimon - Battle Spirit 2
    "BDG": Savetype.EEPROM_4k               , // EEPROM_V124     Digimon Racing
    "BDJ": Savetype.EEPROM_4k               , // EEPROM_V124     Digimon Racing
    "AD3": Savetype.EEPROM_4k               , // EEPROM_V122     Dinotopia - The Timestone Pirates
    "AQP": Savetype.NONE                    , // NONE            Disney Princess
    "BQN": Savetype.EEPROM_4k               , // EEPROM_V124     Disney Princess - Royal Adventure
    "A2A": Savetype.EEPROM_4k               , // EEPROM_V122     Disney Sports - Basketball
    "A3D": Savetype.EEPROM_4k               , // EEPROM_V122     Disney Sports - Football
    "AOM": Savetype.EEPROM_4k               , // EEPROM_V122     Disney Sports - Motocross
    "A4D": Savetype.EEPROM_4k               , // EEPROM_V122     Disney Sports - Skateboarding
    "A5D": Savetype.EEPROM_4k               , // EEPROM_V122     Disney Sports - Snowboarding
    "A6D": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Disney Sports - Soccer
    "BD8": Savetype.EEPROM_4k               , // EEPROM_V122     Disney's Party
    "BBK": Savetype.SRAM_256K               , // SRAM_V113       DK - King of Swing
    "B82": Savetype.EEPROM_4k               , // EEPROM_V124     Dogz
    "BFE": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Dogz - Fashion
    "BIM": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Dogz 2
    "ADQ": Savetype.SRAM_256K               , // SRAM_V102       Dokapon
    "A56": Savetype.EEPROM_4k_alt           , // EEPROM_V122     DokiDoki Cooking Series 1 - Komugi-chan no Happy Cake
    "A8O": Savetype.EEPROM_4k_alt           , // EEPROM_V122     DokiDoki Cooking Series 2 - Gourmet Kitchen - Suteki na Obentou
    "AYA": Savetype.SRAM_256K               , // SRAM_V102       Dokodemo Taikyoku - Yakuman Advance
    "ADO": Savetype.SRAM_256K               , // SRAM_V112       Domo-kun no Fushigi Terebi
    "ADK": Savetype.NONE                    , // NONE            Donald Duck Advance
    "AAD": Savetype.NONE                    , // NONE            Donald Duck Advance
    "BDA": Savetype.EEPROM_4k               , // EEPROM_V124     Donchan Puzzle Hanabi de Dohn Advance
    "A5N": Savetype.EEPROM_4k               , // EEPROM_V122     Donkey Kong Country
    "B2D": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Donkey Kong Country 2
    "BDQ": Savetype.EEPROM_4k               , // EEPROM_V124     Donkey Kong Country 3
    "ADM": Savetype.EEPROM_4k               , // EEPROM_V120     Doom
    "A9D": Savetype.EEPROM_4k               , // EEPROM_V120     Doom II
    "BXP": Savetype.NONE                    , // NONE            Dora the Explorer - Dora's World Adventure
    "BER": Savetype.NONE                    , // NONE            Dora the Explorer - Super Spies
    "BDO": Savetype.NONE                    , // NONE            Dora the Explorer - Super Star Adventures!
    "AER": Savetype.NONE                    , // NONE            Dora the Explorer - The Search for the Pirate Pig's Treasure
    "ADP": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Doraemon - Dokodemo Walker
    "ADR": Savetype.SRAM_256K               , // SRAM_V110       Doraemon - Midori no Wakusei DokiDoki Daikyuushutsu!
    "BDD": Savetype.NONE                    , // NONE            Double Dragon Advance
    "A8D": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Doubutsu Shima no Chobi Gurumi
    "BDC": Savetype.EEPROM_4k               , // EEPROM_V124     Doubutsujima no Chobi Gurumi 2 - Tamachan Monogatari
    "ADW": Savetype.NONE                    , // NONE            Downforce
    "A6T": Savetype.EEPROM_4k               , // EEPROM_V121     Dr. Muto
    "AQT": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Dr. Seuss' - The Cat in the Hat
    "BUO": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Dr. Sudoku
    "BDV": Savetype.EEPROM_4k               , // EEPROM_V124     Dragon Ball - Advanced Adventure
    "BT4": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Dragon Ball GT - Transformation
    "BG3": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Dragon Ball Z - Buu's Fury
    "ADZ": Savetype.SRAM_256K               , // SRAM_V102       Dragon Ball Z - Collectible Card Game
    "AZJ": Savetype.EEPROM_4k               , // EEPROM_V124     Dragon Ball Z - Supersonic Warriors
    "BDB": Savetype.EEPROM_4k               , // EEPROM_V122     Dragon Ball Z - Taiketsu
    "ALG": Savetype.EEPROM_4k               , // EEPROM_V122     Dragon Ball Z - The Legacy of Goku
    "ALF": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Dragon Ball Z - The Legacy of Goku II
    "A5G": Savetype.SRAM_256K               , // SRAM_V113       Dragon Drive - World D Break
    "AT2": Savetype.Flash_512k_Atmel        , // FLASH_V121      Dragon Quest Characters - Torneko no Daibouken 2 Advance
    "BD3": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Dragon Quest Characters - Torneko no Daibouken 3 Advance
    "A9H": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Dragon Quest Monsters - Caravan Heart
    "BD9": Savetype.NONE                    , // NONE            Dragon Tales - Dragon Adventures
    "BJD": Savetype.EEPROM_4k               , // EEPROM_V124     Dragon's Rock
    "AJY": Savetype.NONE                    , // NONE            Drake & Josh
    "V49": Savetype.SRAM_256K               , // SRAM_V113       Drill Dozer
    "B3R": Savetype.EEPROM_4k               , // EEPROM_V124     Driv3r
    "ADV": Savetype.EEPROM_4k               , // EEPROM_V120     Driven
    "ADU": Savetype.EEPROM_4k               , // EEPROM_V122     Driver 2 Advance
    "AOE": Savetype.EEPROM_4k               , // EEPROM_V122     Drome Racers
    "AD7": Savetype.NONE                    , // NONE            Droopy's Tennis Open
    "AB9": Savetype.EEPROM_4k               , // EEPROM_V122     Dual Blades
    "BD6": Savetype.EEPROM_4k               , // EEPROM_V124     Duel Masters - Kaijudo Showdown
    "AA9": Savetype.EEPROM_4k               , // EEPROM_V124     Duel Masters - Sempai Legends
    "BDU": Savetype.EEPROM_4k               , // EEPROM_V124     Duel Masters - Shadow of the Code
    "BD2": Savetype.SRAM_256K               , // SRAM_V113       Duel Masters 2
    "BD5": Savetype.SRAM_256K               , // SRAM_V113       Duel Masters 2 - Kirifuda Shoubu Version
    "AD9": Savetype.EEPROM_4k               , // EEPROM_V120     Duke Nukem Advance
    "AD4": Savetype.SRAM_256K               , // SRAM_V102       Dungeons & Dragons - Eye of the Beholder
    "B36": Savetype.SRAM_256K               , // SRAM_V113       Dynasty Warriors Advance
    "AET": Savetype.NONE                    , // NONE            E.T. - The Extra-Terrestrial
    "AEJ": Savetype.NONE                    , // NONE            Earthworm Jim
    "AJ4": Savetype.NONE                    , // NONE            Earthworm Jim 2
    "AES": Savetype.NONE                    , // NONE            Ecks vs Sever
    "AE3": Savetype.EEPROM_4k               , // EEPROM_V122     Ed, Edd n Eddy - Jawbreakers!
    "BED": Savetype.EEPROM_4k               , // EEPROM_V124     Ed, Edd n Eddy - The Mis-Edventures
    "AEM": Savetype.NONE                    , // NONE            Egg Mania
    "AEK": Savetype.EEPROM_4k               , // EEPROM_V122     Elemix!
    "ANW": Savetype.EEPROM_4k               , // EEPROM_V122     Elevator Action - Old & New
    "BEL": Savetype.NONE                    , // NONE            Elf - The Movie
    "BEB": Savetype.NONE                    , // NONE            Elf Bowling 1 & 2
    "BZR": Savetype.EEPROM_4k               , // EEPROM_V124     Enchanted - Once Upon Andalasia
    "BEN": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Eragon
    "PSA": Savetype.Flash_1M_Macronix_RTC   , // FLASH_V103      E-Reader
    "BEJ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Erementar Gerad
    "AGR": Savetype.Flash_512k_SST          , // FLASH_V124      ESPN Final Round Golf 2002
    "AMG": Savetype.SRAM_256K               , // SRAM_V112       ESPN Great Outdoor Games - Bass 2002
    "AWI": Savetype.EEPROM_4k               , // EEPROM_V122     ESPN International Winter Sports 2002
    "AWX": Savetype.EEPROM_4k               , // EEPROM_V122     ESPN Winter X-Games Snowboarding 2002
    "AXS": Savetype.EEPROM_4k               , // EEPROM_V121     ESPN X-Games Skateboarding
    "AEL": Savetype.NONE                    , // NONE            European Super League
    "BEV": Savetype.EEPROM_4k               , // EEPROM_V124     Ever Girl
    "AMO": Savetype.SRAM_256K               , // SRAM_V112       EX Monopoly
    "AEG": Savetype.NONE                    , // NONE            Extreme Ghostbusters - Code Ecto-1
    "BES": Savetype.EEPROM_4k               , // EEPROM_V122     Extreme Skate Adventure
    "BE4": Savetype.SRAM_256K               , // SRAM_V113       Eyeshield 21 - Devilbats Devildays
    "A22": Savetype.SRAM_256K               , // SRAM_V110       EZ-Talk - Shokyuu Hen 1
    "A23": Savetype.SRAM_256K               , // SRAM_V110       EZ-Talk - Shokyuu Hen 2
    "A24": Savetype.SRAM_256K               , // SRAM_V110       EZ-Talk - Shokyuu Hen 3
    "A25": Savetype.SRAM_256K               , // SRAM_V110       EZ-Talk - Shokyuu Hen 4
    "A26": Savetype.SRAM_256K               , // SRAM_V110       EZ-Talk - Shokyuu Hen 5
    "A27": Savetype.SRAM_256K               , // SRAM_V110       EZ-Talk - Shokyuu Hen 6
    "AF8": Savetype.EEPROM_4k               , // EEPROM_V122     F1 2002
    "AFT": Savetype.NONE                    , // NONE            F-14 Tomcat
    "BYA": Savetype.NONE                    , // NONE            F24 - Stealth Fighter
    "FSR": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Famicom Mini Series - Dai 2 Ji Super Robot Taisen
    "FGZ": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series - Kido Senshi Z Gundam Hot Scramble
    "FSO": Savetype.EEPROM_4k               , // EEPROM_V122     Famicom Mini Series 10 - Star Soldier
    "FMB": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 11 - Mario Bros.
    "FCL": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 12 - Clu Clu Land
    "FBF": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 13 - Balloon Fight
    "FWC": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 14 - Wrecking Crew
    "FDD": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 16 - Dig Dug
    "FTB": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 17 - Takahashi Meijin no Bouken Jima
    "FMK": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 18 - Makaimura
    "FTW": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 19 - TwinBee
    "FGG": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 20 - Ganbare Goemon! Karakuri Douchuu
    "FM2": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 21 - Super Mario Bros. 2
    "FNM": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 22 - Nazo no Murasame Shiro
    "FPT": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Famicom Mini Series 24 - Hikari Shinwa - Palutena no Kagame
    "FFM": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 26 - Mukashi Hanashi - Shin Onigashima
    "FTK": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 27 - Famicom Tantei Club - Kieta Koukeisha
    "FTU": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 28 - Famicom Tantei Club Part II - Ushiro ni Tatsu Shoujo
    "FSD": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Famicom Mini Series 30 - SD Gundam World - Gachapon Senshi Scramble Wars
    "FPM": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 6 - Pac-Man
    "FMP": Savetype.EEPROM_4k               , // EEPROM_V124     Famicom Mini Series 8 - Mappy
    "B2F": Savetype.NONE                    , // NONE            Family Feud
    "AAT": Savetype.EEPROM_4k               , // EEPROM_V122     Family Tennis Advance
    "AN7": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Famista Advance
    "AJE": Savetype.SRAM_256K               , // SRAM_V112       Fancy Pocket
    "BFC": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Fantasic Children
    "BF4": Savetype.EEPROM_4k               , // EEPROM_V124     Fantastic 4
    "BH4": Savetype.EEPROM_4k               , // EEPROM_V124     Fantastic 4 - Flame On
    "AAX": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Fantastic Maerchen - Cake-yasan Monogatari
    "BFU": Savetype.EEPROM_4k               , // EEPROM_V124     Fear Factor Unleashed
    "AF9": Savetype.SRAM_256K               , // SRAM_V112       Field of Nine - Digital Edition 2001
    "BF6": Savetype.EEPROM_4k               , // EEPROM_V124     FIFA 06
    "B7F": Savetype.EEPROM_4k               , // EEPROM_V124     FIFA 07
    "AFJ": Savetype.EEPROM_4k               , // EEPROM_V122     FIFA 2003
    "BFI": Savetype.EEPROM_4k               , // EEPROM_V122     FIFA 2004
    "BF5": Savetype.EEPROM_4k               , // EEPROM_V124     FIFA 2005
    "B6W": Savetype.EEPROM_4k               , // EEPROM_V124     FIFA World Cup 2006
    "BOX": Savetype.EEPROM_4k               , // EEPROM_V122     FightBox
    "AFL": Savetype.EEPROM_4k               , // EEPROM_V122     FILA Decathlon
    "BFF": Savetype.SRAM_256K               , // SRAM_V113       Final Fantasy I & II - Dawn of Souls
    "BZ4": Savetype.SRAM_256K               , // SRAM_V113       Final Fantasy IV Advance
    "AFX": Savetype.Flash_512k_Panasonic    , // FLASH_V130      Final Fantasy Tactics Advance
    "BZ5": Savetype.SRAM_256K               , // SRAM_V113       Final Fantasy V Advance
    "BZ6": Savetype.SRAM_256K               , // SRAM_V113       Final Fantasy VI Advance
    "AFF": Savetype.EEPROM_4k               , // EEPROM_V121     Final Fight One
    "AFW": Savetype.Flash_512k_SST          , // FLASH_V126      Final Fire Pro Wrestling - Yume no Dantai Unei!
    "AZI": Savetype.NONE                    , // NONE            Finding Nemo
    "BFN": Savetype.NONE                    , // NONE            Finding Nemo
    "BZI": Savetype.NONE                    , // NONE            Finding Nemo - The Continuing Adventures
    "AE7": Savetype.SRAM_256K               , // SRAM_V102       Fire Emblem
    "AFE": Savetype.SRAM_256K               , // SRAM_V102       Fire Emblem - Fuuin no Tsurugi
    "BE8": Savetype.SRAM_256K               , // SRAM_V103       Fire Emblem - The Sacred Stones
    "AFP": Savetype.Flash_512k_Atmel        , // FLASH_V123      Fire Pro Wrestling
    "AFY": Savetype.Flash_512k_SST          , // FLASH_V126      Fire Pro Wrestling 2
    "BLH": Savetype.NONE                    , // NONE            Flushed Away
    "BF3": Savetype.NONE                    , // NONE            Ford Racing 3
    "AFM": Savetype.SRAM_256K               , // SRAM_V112       Formation Soccer 2002
    "AFO": Savetype.NONE                    , // NONE            Fortress
    "BFY": Savetype.EEPROM_4k               , // EEPROM_V124     Foster's Home for Imaginary Friends
    "BFK": Savetype.EEPROM_4k               , // EEPROM_V124     Franklin the Turtle
    "BFL": Savetype.EEPROM_4k               , // EEPROM_V124     Franklin's Great Adventures
    "BFS": Savetype.NONE                    , // NONE            Freekstyle
    "AFQ": Savetype.NONE                    , // NONE            Frogger Advance - The Great Quest
    "AFR": Savetype.EEPROM_4k               , // EEPROM_V121     Frogger's Adventures - Temple of the Frog
    "AFB": Savetype.EEPROM_4k               , // EEPROM_V122     Frogger's Adventures 2 - The Lost Wand
    "BFJ": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Frogger's Journey - The Forgotten Relic
    "ADC": Savetype.NONE                    , // NONE            Fruit Chase
    "BFD": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Fruit Mura no Doubutsu Tachi
    "AF4": Savetype.EEPROM_4k               , // EEPROM_V122     Fushigi no Kuni no Alice
    "AFA": Savetype.SRAM_256K               , // SRAM_V110       Fushigi no Kuni no Angelique
    "BFP": Savetype.EEPROM_4k               , // EEPROM_V124     Futari ha Precure Arienaai Yume no Kuni ha Daimeikyuu
    "BFM": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Futari wa Precure Max Heart Maji! Maji! Fight de IN Janai
    "BFT": Savetype.Flash_1M_Macronix       , // FLASH_V102      F-Zero - Climax
    "BFZ": Savetype.SRAM_256K               , // SRAM_V113       F-Zero - GP Legends
    "AFZ": Savetype.SRAM_256K               , // SRAM_V111       F-Zero - Maximum Velocity
    "A4X": Savetype.EEPROM_4k               , // EEPROM_V124     Gachaste! Dino Device 2 Dragon
    "A4W": Savetype.EEPROM_4k               , // EEPROM_V124     Gachaste! Dino Device 2 Phoenix
    "ABI": Savetype.Flash_512k_SST          , // FLASH_V126      Gachasute! Dino Device - Blue
    "AAI": Savetype.Flash_512k_SST          , // FLASH_V126      Gachasute! Dino Device - Red
    "ANY": Savetype.SRAM_256K               , // SRAM_V102       Gachinko Pro Yakyuu
    "AQA": Savetype.SRAM_256K               , // SRAM_V112       Gadget Racers
    "AQ2": Savetype.SRAM_256K               , // SRAM_V102       Gadget Racers
    "BGH": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Gakkou no Kaidan - Hyakuyobako no Fuuin
    "AYS": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Gakkou wo Tsukurou!! Advance
    "BAS": Savetype.SRAM_256K               , // SRAM_V113       Gakuen Alice - DokiDoki Fushigi Taiken
    "BGS": Savetype.EEPROM_4k               , // EEPROM_V124     Gakuen Senki Muryou
    "AGZ": Savetype.EEPROM_4k               , // EEPROM_V122     Galaxy Angel GameBoy Advance
    "AG8": Savetype.EEPROM_4k               , // EEPROM_V122     Galidor - Defenders of the Outer Dimension
    "ATY": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Gambler Densetsu Tetsuya - Yomigaeru Densetsu
    "AQW": Savetype.SRAM_256K               , // SRAM_V102       Game & Watch Gallery 4
    "BGW": Savetype.Flash_1M_Macronix       , // FLASH_V102      Gameboy Wars Advance 1+2
    "BG7": Savetype.NONE                    , // NONE            Games Explosion!
    "BG8": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Ganbare! Dodge Fighters
    "BGO": Savetype.NONE                    , // NONE            Garfield - The Search for Pooky
    "BG9": Savetype.EEPROM_4k               , // EEPROM_V124     Garfield and His Nine Lives
    "AYG": Savetype.EEPROM_4k               , // EEPROM_V122     Gauntlet - Dark Legacy
    "B69": Savetype.NONE                    , // NONE            Gauntlet - Rampart
    "MGU": Savetype.NONE                    , // NONE            GBA Video - All Grown Up - Volume 1
    "MCM": Savetype.NONE                    , // NONE            GBA Video - Cartoon Network Collection - Limited Edition
    "MCN": Savetype.NONE                    , // NONE            GBA Video - Cartoon Network Collection - Platinum Edition
    "MCP": Savetype.NONE                    , // NONE            GBA Video - Cartoon Network Collection - Premium Edition
    "MCS": Savetype.NONE                    , // NONE            GBA Video - Cartoon Network Collection - Special Edition
    "MCT": Savetype.NONE                    , // NONE            GBA Video - Cartoon Network Collection - Volume 1
    "MC2": Savetype.NONE                    , // NONE            GBA Video - Cartoon Network Collection - Volume 2
    "MKD": Savetype.NONE                    , // NONE            GBA Video - Codename Kids Next Door - Volume 1
    "MDC": Savetype.NONE                    , // NONE            GBA Video - Disney Channel Collection - Volume 1
    "MDS": Savetype.NONE                    , // NONE            GBA Video - Disney Channel Collection - Volume 2
    "MDR": Savetype.NONE                    , // NONE            GBA Video - Dora the Explorer - Volume 1
    "MDB": Savetype.NONE                    , // NONE            GBA Video - Dragon Ball GT - Volume 1
    "MNC": Savetype.NONE                    , // NONE            GBA Video - Nicktoon's Collection - Volume 1
    "MN2": Savetype.NONE                    , // NONE            GBA Video - Nicktoons Collection - Volume 2
    "MN3": Savetype.NONE                    , // NONE            GBA Video - Nicktoons Volume 3
    "MPA": Savetype.NONE                    , // NONE            GBA Video - Pokemon - Volume 1
    "MPB": Savetype.NONE                    , // NONE            GBA Video - Pokemon - Volume 2
    "MPC": Savetype.NONE                    , // NONE            GBA Video - Pokemon - Volume 3
    "MPD": Savetype.NONE                    , // NONE            GBA Video - Pokemon - Volume 4
    "MSA": Savetype.NONE                    , // NONE            GBA Video - Shark Tale
    "MSK": Savetype.NONE                    , // NONE            GBA Video - Shrek
    "MST": Savetype.NONE                    , // NONE            GBA Video - Shrek + Shark Tale
    "M2S": Savetype.NONE                    , // NONE            GBA Video - Shrek 2
    "MSH": Savetype.NONE                    , // NONE            GBA Video - Sonic X - Volume 1
    "MSS": Savetype.NONE                    , // NONE            GBA Video - SpongeBob SquarePants - Volume 1
    "MS2": Savetype.NONE                    , // NONE            GBA Video - SpongeBob SquarePants - Volume 2
    "MS3": Savetype.NONE                    , // NONE            GBA Video - SpongeBob SquarePants - Volume 3
    "MSB": Savetype.NONE                    , // NONE            GBA Video - Strawberry Shortcake - Volume 1
    "MSR": Savetype.NONE                    , // NONE            GBA Video - Super Robot Monkey Team - Volume 1
    "MTM": Savetype.NONE                    , // NONE            GBA Video - Teenage Mutant Ninja Turtles - Volume 1
    "MJM": Savetype.NONE                    , // NONE            GBA Video - The Adventures of Jimmy Neutron Boy Genius - Volume 1
    "MFO": Savetype.NONE                    , // NONE            GBA Video - The Fairly Odd Parents - Volume 1
    "MF2": Savetype.NONE                    , // NONE            GBA Video - The Fairly Odd Parents - Volume 2
    "MFP": Savetype.NONE                    , // NONE            GBA Video - The Proud Family - Volume 1
    "MYG": Savetype.NONE                    , // NONE            GBA Video - Yu-Gi-Oh! - Yugi vs. Joey - Volume 1
    "AGB": Savetype.NONE                    , // NONE            GBA-SP AV Adaptor
    "BGK": Savetype.SRAM_256K               , // SRAM_V112       Gegege no Kitarou - Kikiippatsu! Youkai Rettou
    "AGE": Savetype.NONE                    , // NONE            Gekido Advance - Kintaro's Revenge
    "ANN": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Gekitou Densetsu Noah - Dream Management
    "AZS": Savetype.EEPROM_4k               , // EEPROM_V122     Gem Smashers
    "BGJ": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Genseishin the Justirisers - Souchaku Chikyuu no
    "BGM": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Gensou Maden Saiyuuki - Hangyaku no Toushin-taishi
    "AGK": Savetype.NONE                    , // NONE            Gensou Suikoden - Card Stories
    "BGI": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Get Ride AMDriver - Senkou no Hero Tanjou
    "BGP": Savetype.SRAM_256K               , // SRAM_V113       Get Ride! AMDrive Shutsugeki Battle Party
    "BGB": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Get! - Boku no Mushi Tsukamaete
    "BGF": Savetype.SRAM_256K               , // SRAM_V113       GetBackers Dakkanya - Jagan Fuuin!
    "A8G": Savetype.Flash_512k_Panasonic    , // FLASH_V131      GetBackers Dakkanya - Metropolis Dakkan Sakusen!
    "BR8": Savetype.EEPROM_4k               , // EEPROM_V124     Ghost Rider
    "AGV": Savetype.EEPROM_4k               , // EEPROM_V122     Ghost Trap
    "B3Z": Savetype.EEPROM_4k               , // EEPROM_V124     Global Star - Suduoku Feber
    "AGQ": Savetype.EEPROM_4k               , // EEPROM_V122     Go! Go! Beckham! - Adventure on Soccer Island
    "AG4": Savetype.NONE                    , // NONE            Godzilla - Domination!
    "AGN": Savetype.EEPROM_4k_alt           , // EEPROM_V121     Goemon - New Age Shutsudou!
    "BGG": Savetype.NONE                    , // NONE            Golden Nugget Casino
    "AGS": Savetype.Flash_512k_Atmel        , // FLASH_V123      Golden Sun
    "AGF": Savetype.Flash_512k_Atmel        , // FLASH_V123      Golden Sun - The Lost Age
    "AGA": Savetype.EEPROM_4k               , // EEPROM_V122     Gradius Galaxies
    "BGT": Savetype.EEPROM_4k               , // EEPROM_V124     Grand Theft Auto Advance
    "AG9": Savetype.SRAM_256K               , // SRAM_V102       Greatest Nine
    "BUS": Savetype.EEPROM_4k               , // EEPROM_V122     Green Eggs and Ham by Dr. Seuss
    "BGQ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Greg Hastings' Tournament Paintball Max'd
    "AGG": Savetype.NONE                    , // NONE            Gremlins - Stripe vs Gizmo
    "ARV": Savetype.SRAM_256K               , // SRAM_V112       Groove Adventure Rave - Hikari to Yami no Daikessen
    "ARI": Savetype.SRAM_256K               , // SRAM_V112       Groove Adventure Rave - Hikari to Yami no Daikessen 2
    "ACA": Savetype.NONE                    , // NONE            GT Advance - Championship Racing
    "AGW": Savetype.EEPROM_4k               , // EEPROM_V122     GT Advance 2 - Rally Racing
    "A2G": Savetype.EEPROM_4k               , // EEPROM_V122     GT Advance 3 - Pro Concept Racing
    "BJA": Savetype.NONE                    , // NONE            GT Racers
    "AGX": Savetype.Flash_512k_SST          , // FLASH_V124      Guilty Gear X - Advance Edition
    "BGV": Savetype.EEPROM_4k               , // EEPROM_V124     Gumby vs. The Astrobots
    "BHG": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Gunstar Super Heroes
    "BGX": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Gunstar Super Heroes
    "AIB": Savetype.SRAM_256K               , // SRAM_V112       Guranbo
    "AGC": Savetype.Flash_512k_SST          , // FLASH_V126      Guru Logic Champ
    "ASB": Savetype.SRAM_256K               , // SRAM_V112       Gyakuten Saiban
    "A3G": Savetype.SRAM_256K               , // SRAM_V112       Gyakuten Saiban 2
    "A3J": Savetype.SRAM_256K               , // SRAM_V112       Gyakuten Saiban 3
    "A8E": Savetype.EEPROM_4k               , // EEPROM_V122     Hachiemon
    "BHR": Savetype.EEPROM_4k               , // EEPROM_V124     Hagane no Renkinjutsushi - Meisou no Rondo
    "BH2": Savetype.EEPROM_4k               , // EEPROM_V120     Hagane no Renkinjutsushi - Omoide no Sonata
    "A2H": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Hajime no Ippo - The Fighting!
    "AM7": Savetype.SRAM_256K               , // SRAM_V102       Hamepane - Tokyo Mew Mew
    "A4K": Savetype.SRAM_256K               , // SRAM_V113       Hamster Club 4
    "AHB": Savetype.SRAM_256K               , // SRAM_V110       Hamster Monogatari 2 GBA
    "A83": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Hamster Monogatari 3 GBA
    "BHS": Savetype.EEPROM_4k               , // EEPROM_V124     Hamster Monogatari 3EX 4 Special
    "BHC": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Hamster Monogatari Collection
    "A82": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Hamster Paradise - Pure Heart
    "AHA": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Hamster Paradise Advance
    "B85": Savetype.SRAM_256K               , // SRAM_V113       Hamtaro - Ham-Ham Games
    "AH3": Savetype.SRAM_256K               , // SRAM_V103       Hamtaro - Ham-Ham Heartbreak
    "A84": Savetype.SRAM_256K               , // SRAM_V113       Hamtaro - Rainbow Rescue
    "BHA": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Hanabi Hyakkei Advance
    "ADY": Savetype.EEPROM_4k               , // EEPROM_V122     Hanafuda Trump Mahjong - Depachika Wayouchuu
    "BH3": Savetype.EEPROM_4k_alt           , // EEPROM_V126     Happy Feet
    "AH6": Savetype.EEPROM_4k               , // EEPROM_V122     Hardcore Pinball
    "BHO": Savetype.NONE                    , // NONE            Hardcore Pool
    "BHN": Savetype.NONE                    , // NONE            Harlem Globetrotters - World Tour
    "BH6": Savetype.EEPROM_4k               , // EEPROM_V124     Haro no Puyo Puyo
    "AHQ": Savetype.SRAM_256K               , // SRAM_V112       Harobots - Robo Hero Battling!!
    "BHP": Savetype.EEPROM_4k               , // EEPROM_V122     Harry Potter - Quidditch World Cup
    "A7H": Savetype.EEPROM_4k               , // EEPROM_V122     Harry Potter and the Chamber of Secrets
    "BH8": Savetype.EEPROM_4k_alt           , // EEPROM_V126     Harry Potter and the Goblet of Fire
    "BJX": Savetype.EEPROM_4k               , // EEPROM_V124     Harry Potter and the Order of the Phoenix
    "BHT": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Harry Potter and the Prisoner of Azkaban
    "AHR": Savetype.EEPROM_4k               , // EEPROM_V122     Harry Potter and the Sorcerer's Stone
    "BJP": Savetype.EEPROM_8k               , // EEPROM_V126     Harry Potter Collection
    "ARN": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Harukanaru Toki no Naka de
    "A4N": Savetype.SRAM_256K               , // SRAM_V113       Harvest Moon - Friends of Mineral Town
    "BFG": Savetype.SRAM_256K               , // SRAM_V113       Harvest Moon - More Friends of Mineral Town
    "AHS": Savetype.SRAM_256K               , // SRAM_V110       Hatena Satena
    "BHJ": Savetype.EEPROM_4k               , // EEPROM_V124     Heidi
    "BHD": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Hello Idol Debut
    "B86": Savetype.NONE                    , // NONE            Hello Kitty - Happy Party Pals
    "AKT": Savetype.EEPROM_4k_alt           , // EEPROM_V121     Hello Kitty Collection - Miracle Fashion Maker
    "B8F": Savetype.EEPROM_4k               , // EEPROM_V124     Herbie Fully Loaded
    "AAE": Savetype.NONE                    , // NONE            Hey Arnold! - The Movie
    "BHH": Savetype.EEPROM_4k               , // EEPROM_V124     Hi Hi Puffy - AmiYumi Kaznapped
    "AHZ": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Higanbana
    "ASS": Savetype.EEPROM_4k               , // EEPROM_V122     High Heat - Major League Baseball 2002
    "AHH": Savetype.EEPROM_4k_alt           , // EEPROM_V122     High Heat - Major League Baseball 2003
    "AHX": Savetype.EEPROM_4k_alt           , // EEPROM_V122     High Heat - Major League Baseball 2003
    "BJ2": Savetype.EEPROM_4k               , // EEPROM_V124     High School Musical - Livin' the Dream
    "AHK": Savetype.SRAM_256K               , // SRAM_V102       Hikaru no Go
    "AHT": Savetype.NONE                    , // NONE            Hikaru no Go - Taikenban
    "AKE": Savetype.SRAM_256K               , // SRAM_V102       Hikaru no Go 2
    "A3H": Savetype.SRAM_256K               , // SRAM_V112       Hime Kishi Monogatari - Princess Blue
    "AHI": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Hitsuji no Kimochi
    "BHM": Savetype.NONE                    , // NONE            Home on the Range
    "BYP": Savetype.EEPROM_8k               , // EEPROM_V124     Horse & Pony - Let's Ride 2
    "BHU": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Horsez
    "AHP": Savetype.EEPROM_4k               , // EEPROM_V120     Hot Potato!
    "AHW": Savetype.EEPROM_4k               , // EEPROM_V121     Hot Wheels - Burnin' Rubber
    "BHE": Savetype.NONE                    , // NONE            Hot Wheels - Stunt Track Challenge
    "AH8": Savetype.NONE                    , // NONE            Hot Wheels - Velocity X
    "BHW": Savetype.NONE                    , // NONE            Hot Wheels - World Race
    "BHX": Savetype.NONE                    , // NONE            Hot Wheels All Out
    "B7I": Savetype.NONE                    , // NONE            Hudson Best Collection 1
    "B74": Savetype.NONE                    , // NONE            Hudson Best Collection Vol. 4 - Nazotoki Collection
    "B75": Savetype.NONE                    , // NONE            Hudson Best Collection Vol. 5 - Shooting Collection
    "B76": Savetype.NONE                    , // NONE            Hudson Best Collection Vol. 6 - Bouken Jima Collection
    "B72": Savetype.NONE                    , // NONE            Hudson Collection Vol. 2 - Lode Runner Collection
    "B73": Savetype.NONE                    , // NONE            Hudson Collection Vol. 3 - Action Collection
    "AZH": Savetype.NONE                    , // NONE            Hugo - Bukkazoom!
    "AHJ": Savetype.EEPROM_4k               , // EEPROM_V124     Hugo - The Evil Mirror
    "B2H": Savetype.EEPROM_4k               , // EEPROM_V124     Hugo 2 in 1 - Bukkazoom! + The Evil Mirror
    "A8N": Savetype.SRAM_256K               , // SRAM_V112       Hunter X Hunter - Minna Tomodachi Daisakusen!!
    "A4C": Savetype.EEPROM_4k               , // EEPROM_V122     I Spy Challenger!
    "AIA": Savetype.NONE                    , // NONE            Ice Age
    "BIA": Savetype.EEPROM_4k               , // EEPROM_V124     Ice Age 2 - The Meltdown
    "AR3": Savetype.EEPROM_4k               , // EEPROM_V120     Ice Nine
    "BIV": Savetype.NONE                    , // NONE            Ignition Collection - Volume 1 (3 Games in 1)
    "AIN": Savetype.SRAM_256K               , // SRAM_V112       Initial D - Another Stage
    "AIG": Savetype.NONE                    , // NONE            Inspector Gadget - Advance Mission
    "AIR": Savetype.NONE                    , // NONE            Inspector Gadget Racing
    "AIK": Savetype.NONE                    , // NONE            International Karate Advanced
    "A3K": Savetype.NONE                    , // NONE            International Karate Plus
    "AIS": Savetype.EEPROM_4k_alt           , // EEPROM_V120     International Superstar Soccer
    "AY2": Savetype.EEPROM_4k_alt           , // EEPROM_V122     International Superstar Soccer Advance
    "AI9": Savetype.SRAM_256K               , // SRAM_V112       Inukko Club
    "AIY": Savetype.SRAM_256K               , // SRAM_V112       Inuyasha - Naraku no Wana! Mayoi no Mori no Shoutaijou
    "AIV": Savetype.NONE                    , // NONE            Invader
    "AI3": Savetype.NONE                    , // NONE            Iridion 3D
    "AI2": Savetype.NONE                    , // NONE            Iridion II
    "BIR": Savetype.EEPROM_4k               , // EEPROM_V124     Iron Kid
    "AXT": Savetype.EEPROM_4k               , // EEPROM_V122     Island Xtreme Stunts
    "AIE": Savetype.SRAM_256K               , // SRAM_V112       Isseki Hattyou - Kore 1ppon de 8syurui!
    "BPI": Savetype.EEPROM_4k_alt           , // EEPROM_V124     It's Mr Pants
    "A2J": Savetype.EEPROM_4k_alt           , // EEPROM_V121     J.League - Winning Eleven Advance 2002
    "AJP": Savetype.SRAM_256K               , // SRAM_V110       J.League Pocket
    "AJ2": Savetype.SRAM_256K               , // SRAM_V112       J.League Pocket 2
    "AC2": Savetype.SRAM_256K               , // SRAM_V112       J.League Pro Soccer Club wo Tsukurou! Advance
    "AJC": Savetype.EEPROM_4k               , // EEPROM_V120     Jackie Chan Adventures - Legend of the Darkhand
    "BNJ": Savetype.EEPROM_4k               , // EEPROM_V122     Jajamaru Jr. Denshouki - Jaleco Memorial
    "A7O": Savetype.EEPROM_4k               , // EEPROM_V122     James Bond 007 - NightFire
    "AJD": Savetype.NONE                    , // NONE            James Pond - Codename Robocod
    "AJJ": Savetype.EEPROM_4k               , // EEPROM_V120     Jazz Jackrabbit
    "AJR": Savetype.EEPROM_4k               , // EEPROM_V122     Jet Set Radio
    "AGM": Savetype.Flash_512k_SST          , // FLASH_V124      JGTO Kounin Golf Master Mobile - Japan Golf Tour Game
    "AJW": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Jikkyou World Soccer Pocket
    "AJK": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Jikkyou World Soccer Pocket 2
    "AJN": Savetype.NONE                    , // NONE            Jimmy Neutron - Boy Genius
    "BJY": Savetype.EEPROM_4k               , // EEPROM_V124     Jimmy Neutron Boy Genius - Attack of the Twonkies
    "AZG": Savetype.SRAM_256K               , // SRAM_V112       Jinsei Game Advance
    "AJU": Savetype.Flash_512k_SST          , // FLASH_V126      Jissen Pachi-Slot Hisshouhou! - Juuou Advance
    "AJM": Savetype.EEPROM_4k               , // EEPROM_V121     Jonny Moseley Mad Trix
    "BJK": Savetype.EEPROM_4k               , // EEPROM_V124     Juka and the Monophonic Menace
    "AJQ": Savetype.EEPROM_4k               , // EEPROM_V122     Jurassic Park III - Island Attack
    "AJ3": Savetype.SRAM_256K               , // SRAM_V102       Jurassic Park III - Park Builder
    "ADN": Savetype.EEPROM_4k               , // EEPROM_V121     Jurassic Park III - The DNA Factor
    "AJ8": Savetype.EEPROM_4k               , // EEPROM_V122     Jurassic Park Institute Tour - Dinosaur Rescue
    "AJL": Savetype.EEPROM_4k               , // EEPROM_V122     Justice League - Injustice for All
    "BJL": Savetype.EEPROM_4k               , // EEPROM_V120     Justice League Chronicles
    "BJH": Savetype.EEPROM_4k               , // EEPROM_V124     Justice League Heroes - The Flash
    "AKV": Savetype.EEPROM_4k_alt           , // EEPROM_V122     K-1 Pocket Grand Prix
    "A2O": Savetype.EEPROM_4k_alt           , // EEPROM_V122     K-1 Pocket Grand Prix 2
    "AKD": Savetype.SRAM_256K               , // SRAM_V102       Kaeru B Back
    "BKO": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Kaiketsu Zorori to Mahou no Yuuenchi
    "AKZ": Savetype.Flash_512k_SST          , // FLASH_V126      Kamaitachi no Yoru Advance
    "AG2": Savetype.SRAM_256K               , // SRAM_V112       Kami no Kijutsu - Illusion of the Evil Eyes
    "AKK": Savetype.NONE                    , // NONE            Kao the Kangaroo
    "BK8": Savetype.SRAM_256K               , // SRAM_V113       Kappa no Kai-Kata - Katan Daibouken
    "AYK": Savetype.NONE                    , // NONE            Karnaaj Rally
    "AN5": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Kawa no Nushi Tsuri 5 - Fushigi no Mori Kara
    "BN4": Savetype.SRAM_256K               , // SRAM_V113       Kawa no Nushitsuri 3 & 4
    "BKG": Savetype.NONE                    , // NONE            Kawaii Pet Game Gallery
    "BKP": Savetype.EEPROM_4k               , // EEPROM_V124     Kawaii Pet Game Gallery 2
    "A63": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Kawaii Pet Shop Monogatari 3
    "ATP": Savetype.Flash_512k_SST          , // FLASH_V126      Keitai Denjuu Telefang 2 - Power
    "ATS": Savetype.Flash_512k_SST          , // FLASH_V126      Keitai Denjuu Telefang 2 - Speed
    "AS3": Savetype.EEPROM_4k               , // EEPROM_V122     Kelly Slater's Pro Surfer
    "BKJ": Savetype.SRAM_256K               , // SRAM_V113       Keroro Gunsou Taiketsu Gekisou
    "BG2": Savetype.EEPROM_4k               , // EEPROM_V124     Kessakusen Ganbare Goemon 1 and 2
    "BYL": Savetype.EEPROM_4k               , // EEPROM_V124     Kid Paddle
    "B42": Savetype.EEPROM_4k               , // EEPROM_V124     Kidou Senshi Gundam Seed Destiny
    "AAL": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Kidou Tenshi Angelic Layer - Misaki to Yume no Tenshi-tachi
    "BCX": Savetype.NONE                    , // NONE            Kid's Cards
    "XXX": Savetype.NONE                    , // NONE            Kien
    "AKI": Savetype.NONE                    , // NONE            Kiki KaiKai Advance
    "BKH": Savetype.EEPROM_4k               , // EEPROM_V124     Kill Switch
    "B3L": Savetype.NONE                    , // NONE            Killer 3D Pool
    "AEY": Savetype.NONE                    , // NONE            Kim Possible - Revenge of Monkey Fist
    "BKM": Savetype.EEPROM_4k               , // EEPROM_V124     Kim Possible 2 - Drakken's Demise
    "BQP": Savetype.EEPROM_4k               , // EEPROM_V124     Kim Possible 3 - Team Possible
    "B8C": Savetype.SRAM_256K               , // SRAM_V103       Kingdom Hearts - Chain of Memories
    "AK5": Savetype.SRAM_256K               , // SRAM_V112       Kinniku Banzuke - Kimero! Kiseki no Kanzen Seiha
    "AK4": Savetype.SRAM_256K               , // SRAM_V112       Kinniku Banzuke - Kongou-kun no Daibouken!
    "A7K": Savetype.SRAM_256K               , // SRAM_V112       Kirby - Nightmare in Dream Land
    "B8K": Savetype.SRAM_256K               , // SRAM_V113       Kirby & the Amazing Mirror
    "BWA": Savetype.EEPROM_4k               , // EEPROM_V124     Kisekae Angel Series 1 - Wannyan Aidoru Gakuen
    "BE2": Savetype.EEPROM_4k               , // EEPROM_V124     Kisekae Angel Series 2 - Charisma Tenin Ikusei Game
    "A2V": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Kisekko Gurumi - Chesty to Nuigurumi-tachi no Mahou no Bouken
    "B2K": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Kiss x Kiss - Seirei Gakuen
    "AKM": Savetype.SRAM_256K               , // SRAM_V112       Kiwame Mahjong Deluxe - Mirai Senshi 21
    "AKL": Savetype.EEPROM_4k               , // EEPROM_V121     Klonoa - Empire of Dreams
    "AN6": Savetype.EEPROM_4k               , // EEPROM_V124     Klonoa 2 - Dream Champ Tournament
    "AK7": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Klonoa Heroes - Densetsu no Star Medal
    "BDI": Savetype.EEPROM_4k               , // EEPROM_V122     Koinu to Issho - Aijou Monogatari
    "BI2": Savetype.EEPROM_4k               , // EEPROM_V124     Koinu to Issho! 2
    "BIS": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Koinu-Chan no Hajimete no Osanpo - Koinu no Kokoro Ikusei Game
    "AKC": Savetype.NONE                    , // NONE            Konami Collector's Series - Arcade Advanced
    "AKW": Savetype.SRAM_256K               , // SRAM_V111       Konami Krazy Racers
    "BQB": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Konchu Monster Battle Master
    "BQS": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Konchu Monster Battle Stadium
    "BQK": Savetype.EEPROM_4k               , // EEPROM_V124     Konchuu no Mori no Daibouken
    "BK7": Savetype.NONE                    , // NONE            Kong - King of Atlantis
    "BKQ": Savetype.EEPROM_4k               , // EEPROM_V124     Kong - The 8th Wonder of the World
    "AKQ": Savetype.NONE                    , // NONE            Kong - The Animated Series
    "BKE": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Konjiki no Gashbell - The Card Battle for GBA
    "BKB": Savetype.SRAM_256K               , // SRAM_V103       Konjiki no Gashbell!! Makai no Bookmark
    "BGY": Savetype.EEPROM_4k               , // EEPROM_V124     Konjiki no Gashbell!! Unare Yuujou no Dengeki
    "BUD": Savetype.EEPROM_4k               , // EEPROM_V124     Konjiki no Gashbell!! Yuujou no Dengeki Dream Tag Tournament
    "KHP": Savetype.EEPROM_4k               , // EEPROM_V122     Koro Koro Puzzle - Happy Panechu!
    "BK5": Savetype.SRAM_256K               , // SRAM_V103       Korokke Great Toki no Boukensha
    "A8M": Savetype.SRAM_256K               , // SRAM_V102       Kotoba no Puzzle - Mojipittan Advance
    "BK6": Savetype.SRAM_256K               , // SRAM_V113       Kouchu Ouja - Mushi King
    "A54": Savetype.SRAM_256K               , // SRAM_V112       Koukou Juken Advance Series Eigo Koubun Hen - 26 Units Shuuroku
    "A53": Savetype.SRAM_256K               , // SRAM_V112       Koukou Juken Advance Series Eijukugo Hen - 650 Phrases Shuuroku
    "A52": Savetype.SRAM_256K               , // SRAM_V112       Koukou Juken Advance Series Eitango Hen - 2000 Words Shuuroku
    "B9A": Savetype.NONE                    , // NONE            Kunio kun Nekketsu Collection 1
    "B9B": Savetype.NONE                    , // NONE            Kunio Kun Nekketsu Collection 2
    "B9C": Savetype.NONE                    , // NONE            Kuniokun Nekketsu Collection 3
    "AGO": Savetype.SRAM_256K               , // SRAM_V112       Kurohige no Golf Shiyouyo
    "AKU": Savetype.SRAM_256K               , // SRAM_V112       Kurohige no Kurutto Jintori
    "AKR": Savetype.SRAM_256K               , // SRAM_V111       Kurukuru Kururin
    "A9Q": Savetype.SRAM_256K               , // SRAM_V112       Kururin Paradise
    "ALD": Savetype.EEPROM_4k               , // EEPROM_V122     Lady Sia
    "AVD": Savetype.SRAM_256K               , // SRAM_V112       Legend of Dynamic - Goushouden - Houkai no Rondo
    "A2L": Savetype.EEPROM_4k               , // EEPROM_V122     Legends of Wrestling II
    "BLV": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Legendz - Sign of Necrom
    "BLJ": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Legendz - Yomigaeru Shiren no Shima
    "ALB": Savetype.SRAM_256K               , // SRAM_V112       LEGO Bionicle
    "AL2": Savetype.SRAM_256K               , // SRAM_V112       LEGO Island 2 - The Brickster's Revenge
    "BKN": Savetype.NONE                    , // NONE            LEGO Knights Kingdom
    "ALR": Savetype.EEPROM_4k               , // EEPROM_V120     LEGO Racers 2
    "BLW": Savetype.EEPROM_4k               , // EEPROM_V124     LEGO Star Wars - The Video Game
    "BL7": Savetype.EEPROM_4k               , // EEPROM_V124     LEGO Star Wars II - The Original Trilogy
    "BLY": Savetype.EEPROM_4k               , // EEPROM_V124     Lemony Snicket's A Series of Unfortunate Events
    "BEF": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Let's Ride - Friends Forever
    "B34": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Let's Ride! - Sunshine Stables
    "BL9": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Let's Ride! Dreamer
    "BRN": Savetype.SRAM_256K               , // SRAM_V113       Licca-Chan no Oshare Nikki
    "BRP": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Liliput Oukoku
    "ALT": Savetype.NONE                    , // NONE            Lilo & Stitch
    "BLS": Savetype.EEPROM_4k               , // EEPROM_V124     Lilo & Stitch 2 - Hamsterveil Havoc
    "ALQ": Savetype.SRAM_256K               , // SRAM_V102       Little Buster Q
    "BEI": Savetype.NONE                    , // NONE            Little Einsteins
    "ALC": Savetype.NONE                    , // NONE            Little League Baseball 2002
    "BLI": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Little Patissier Cake no Oshiro
    "BLM": Savetype.EEPROM_4k_alt           , // EEPROM_V120     Lizzie McGuire
    "BL2": Savetype.EEPROM_4k               , // EEPROM_V124     Lizzie McGuire 2 - Lizzie Diaries
    "BL4": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Lizzie McGuire 2 - Lizzie Diaries - Special Edition
    "BL3": Savetype.EEPROM_4k               , // EEPROM_V124     Lizzie McGuire 3 - Homecoming Havoc
    "A39": Savetype.EEPROM_4k               , // EEPROM_V122     Lode Runner
    "BLT": Savetype.EEPROM_4k               , // EEPROM_V122     Looney Tunes - Back in Action
    "BLN": Savetype.EEPROM_4k               , // EEPROM_V124     Looney Tunes Double Pack - Dizzy Driving + Acme Antics
    "ALH": Savetype.EEPROM_4k               , // EEPROM_V121     Love Hina Advance - Shukufuku no Kane ha Naru Kana
    "ALL": Savetype.NONE                    , // NONE            Lucky Luke - Wanted!
    "AGD": Savetype.SRAM_256K               , // SRAM_V102       Lufia - The Ruins of Lore
    "ALN": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Lunar Legend
    "AML": Savetype.EEPROM_4k               , // EEPROM_V122     M&M's Blast!
    "BEM": Savetype.NONE                    , // NONE            M&M's Break' Em
    "BGZ": Savetype.EEPROM_4k               , // EEPROM_V124     Madagascar
    "BM7": Savetype.EEPROM_4k               , // EEPROM_V124     Madagascar - Operation Penguin
    "B6M": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Madden NFL 06
    "B7M": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Madden NFL 07
    "A2M": Savetype.EEPROM_4k               , // EEPROM_V122     Madden NFL 2002
    "ANJ": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Madden NFL 2003
    "BMD": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Madden NFL 2004
    "BMF": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Madden NFL 2005
    "A2I": Savetype.EEPROM_4k_alt           , // EEPROM_V120     Magi Nation
    "AJO": Savetype.Flash_512k_SST          , // FLASH_V126      Magical Houshin
    "AQM": Savetype.EEPROM_4k               , // EEPROM_V122     Magical Quest 2 Starring Mickey & Minnie
    "BMQ": Savetype.EEPROM_4k               , // EEPROM_V124     Magical Quest 3 Starring Mickey and Donald
    "A3M": Savetype.EEPROM_4k               , // EEPROM_V122     Magical Quest Starring Mickey & Minnie
    "AMV": Savetype.Flash_512k_SST          , // FLASH_V126      Magical Vacation
    "AMP": Savetype.SRAM_256K               , // SRAM_V112       Mahjong Police
    "BNG": Savetype.SRAM_256K               , // SRAM_V113       Mahou Sensei Negima
    "BNM": Savetype.SRAM_256K               , // SRAM_V103       Mahou Sensei Negima! Private Lesson 2
    "AMC": Savetype.Flash_512k_Atmel        , // FLASH_V121      Mail de Cute
    "B2Y": Savetype.NONE                    , // NONE            Major League Baseball 2k7
    "ACO": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Manga-ka Debut Monogatari
    "A4M": Savetype.NONE                    , // NONE            Manic Miner
    "B68": Savetype.NONE                    , // NONE            Marble Madness - Klax
    "BQL": Savetype.NONE                    , // NONE            March of the Penguins
    "BM9": Savetype.SRAM_256K               , // SRAM_V103       Marheaven - Knockin' on Heaven's Door
    "ANS": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Marie, Elie & Anis no Atelier - Soyokaze Kara no Dengon
    "A88": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Mario & Luigi - Superstar Saga
    "BMG": Savetype.SRAM_256K               , // SRAM_V113       Mario Golf - Advance Tour
    "AMK": Savetype.Flash_512k_SST          , // FLASH_V124      Mario Kart - Super Circuit
    "B8M": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Mario Party Advance
    "BMV": Savetype.EEPROM_4k               , // EEPROM_V124     Mario Pinball Land
    "BTM": Savetype.SRAM_256K               , // SRAM_V113       Mario Tennis - Power Tour
    "BM5": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Mario vs. Donkey Kong
    "B4M": Savetype.EEPROM_4k               , // EEPROM_V124     Marvel - Ultimate Alliance
    "AKS": Savetype.EEPROM_4k               , // EEPROM_V120     Mary-Kate and Ashley - Girls Night Out
    "AAY": Savetype.NONE                    , // NONE            Mary-Kate and Ashley Sweet 16 - Licensed to Drive
    "AGU": Savetype.NONE                    , // NONE            Masters of the Universe - He-Man Power of Grayskull
    "AHO": Savetype.EEPROM_4k               , // EEPROM_V122     Mat Hoffman's Pro BMX
    "AH2": Savetype.EEPROM_4k               , // EEPROM_V122     Mat Hoffman's Pro BMX 2
    "BMR": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Matantei Loki Ragnarok - Gensou no Labyrinth
    "ARQ": Savetype.NONE                    , // NONE            Matchbox Cross Town Heroes
    "BIY": Savetype.EEPROM_4k               , // EEPROM_V124     Math Patrol - The Kleptoid Threat
    "BME": Savetype.EEPROM_4k               , // EEPROM_V124     Max Payne
    "BEE": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Maya The Bee - Sweet Gold
    "ABV": Savetype.NONE                    , // NONE            Maya the Bee - The Great Adventure
    "BFQ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Mazes of Fate
    "AKG": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Mech Platoon
    "A8B": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Medabots - Metabee Version
    "A9B": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Medabots - Rokusho Version
    "AK8": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Medabots AX - Metabee Version
    "AK9": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Medabots AX - Rokusho Version
    "BMH": Savetype.EEPROM_4k               , // EEPROM_V120     Medal of Honor - Infiltrator
    "AUG": Savetype.NONE                    , // NONE            Medal of Honor - Underground
    "A5K": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Medarot 2 Core - Kabuto Version
    "A5Q": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Medarot 2 Core - Kuwagata Version
    "AGH": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Medarot G - Kabuto Version
    "AGI": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Medarot G - Kuwagata Version
    "ANA": Savetype.Flash_512k_SST          , // FLASH_V124      Medarot Navi - Kabuto
    "AVI": Savetype.Flash_512k_SST          , // FLASH_V124      Medarot Navi - Kuwagata
    "BRH": Savetype.EEPROM_4k               , // EEPROM_V124     Meet the Robinsons
    "A89": Savetype.SRAM_256K               , // SRAM_V113       MegaMan - Battle Chip Challenge
    "A6M": Savetype.EEPROM_4k_alt           , // EEPROM_V122     MegaMan & Bass
    "ARE": Savetype.SRAM_256K               , // SRAM_V112       MegaMan Battle Network
    "AE2": Savetype.SRAM_256K               , // SRAM_V112       MegaMan Battle Network 2
    "AM2": Savetype.SRAM_256K               , // SRAM_V112       MegaMan Battle Network 2
    "A3X": Savetype.SRAM_256K               , // SRAM_V112       MegaMan Battle Network 3 Blue
    "A6B": Savetype.SRAM_256K               , // SRAM_V112       MegaMan Battle Network 3 White
    "B4B": Savetype.SRAM_256K               , // SRAM_V113       Megaman Battle Network 4 - Blue Moon
    "B4W": Savetype.SRAM_256K               , // SRAM_V113       MegaMan Battle Network 4 - Red Sun
    "BRK": Savetype.SRAM_256K               , // SRAM_V113       Megaman Battle Network 5 - Team Colonel
    "BRB": Savetype.SRAM_256K               , // SRAM_V113       Megaman Battle Network 5 - Team Protoman
    "BR6": Savetype.SRAM_256K               , // SRAM_V113       MegaMan Battle Network 6 - Cybeast Falzar
    "BR5": Savetype.SRAM_256K               , // SRAM_V113       MegaMan Battle Network 6 - Cybeast Gregar
    "AZC": Savetype.SRAM_256K               , // SRAM_V112       MegaMan Zero
    "A62": Savetype.SRAM_256K               , // SRAM_V113       MegaMan Zero 2
    "BZ3": Savetype.SRAM_256K               , // SRAM_V113       Megaman Zero 3
    "B4Z": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Megaman Zero 4
    "BQV": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Meine Tierarztpraxis
    "AC4": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Meitantei Conan - Nerawareta Tantei
    "BQA": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Meitantei Conan Akatsuki no Monument
    "AMI": Savetype.NONE                    , // NONE            Men in Black - The Series
    "B3M": Savetype.SRAM_256K               , // SRAM_V112       Mermaid Melody - Pichi Pichi Picchi Pichi Pichitto Live Start
    "BMA": Savetype.SRAM_256K               , // SRAM_V112       Mermaid Melody - Pichi Pichi Pitch
    "BM8": Savetype.SRAM_256K               , // SRAM_V113       Mermaid Melody - Pichi Pichi Pitch Pichi Pichi Party
    "A9T": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Metal Max 2 - Kai Version
    "BSM": Savetype.EEPROM_4k               , // EEPROM_V124     Metal Slug Advance
    "AAP": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Metalgun Slinger
    "BMX": Savetype.SRAM_256K               , // SRAM_V113       Metroid - Zero Mission
    "AMT": Savetype.SRAM_256K               , // SRAM_V112       Metroid Fusion
    "BMK": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Mezase Koushien
    "BM3": Savetype.EEPROM_4k               , // EEPROM_V124     Mickey to Donald no Magical Quest 3
    "A29": Savetype.EEPROM_4k               , // EEPROM_V122     Mickey to Minnie no Magical Quest 2
    "BM4": Savetype.EEPROM_4k               , // EEPROM_V122     Mickey to Pocket Resort
    "AXZ": Savetype.NONE                    , // NONE            Micro Machines
    "AMQ": Savetype.NONE                    , // NONE            Midnight Club - Street Racing
    "AM3": Savetype.NONE                    , // NONE            Midway's Greatest Arcade Hits
    "BMB": Savetype.EEPROM_4k               , // EEPROM_V124     Mighty Beanz - Pocket Puzzles
    "AM6": Savetype.EEPROM_4k               , // EEPROM_V122     Mike Tyson Boxing
    "AM9": Savetype.EEPROM_4k               , // EEPROM_V122     Mike Tyson Boxing
    "B62": Savetype.NONE                    , // NONE            Millipede - Super Break Out - Lunar Lander
    "AOD": Savetype.EEPROM_4k               , // EEPROM_V122     Minami no Umi no Odyssey
    "AHC": Savetype.SRAM_256K               , // SRAM_V112       Minimoni - Mika no Happy Morning Chatty
    "AOH": Savetype.EEPROM_4k               , // EEPROM_V122     Minimoni - Onegai Ohoshi-sama!
    "BMJ": Savetype.EEPROM_4k               , // EEPROM_V124     Minna no Mahjong
    "BMO": Savetype.SRAM_256K               , // SRAM_V103       Minna no Ouji-sama
    "BKK": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Minna no Shiiku Series - Boku no Kabuto-Kuwagata
    "AB7": Savetype.SRAM_256K               , // SRAM_V112       Minna no Shiiku Series 1 - Boku no Kabuto Mushi
    "AW7": Savetype.SRAM_256K               , // SRAM_V112       Minna no Shiiku Series 2 - Boku no Kuwagata
    "BTL": Savetype.EEPROM_4k               , // EEPROM_V124     Minna no Soft Series - Happy Trump 20
    "BHY": Savetype.EEPROM_4k               , // EEPROM_V124     Minna no Soft Series - Hyokkori Hyoutan-jima - Don Gabacho Daikatsuyaku no Maki
    "BSG": Savetype.EEPROM_4k               , // EEPROM_V124     Minna no Soft Series - Minna no Shogi
    "ARM": Savetype.EEPROM_4k               , // EEPROM_V120     Minority Report
    "B3I": Savetype.EEPROM_4k               , // EEPROM_V124     Mirakuru! Panzou - 7 Tsuno Hosh no Kaizoku
    "AIH": Savetype.EEPROM_4k               , // EEPROM_V122     Mission Impossible - Operation Surma
    "A5M": Savetype.NONE                    , // NONE            MLB SlugFest 20-04
    "AMB": Savetype.Flash_512k_SST          , // FLASH_V124      Mobile Pro Yakyuu - Kantoku no Saihai
    "BGN": Savetype.NONE                    , // NONE            Mobile Suit Gundam Seed - Battle Assault
    "BJC": Savetype.EEPROM_4k               , // EEPROM_V124     Moero! Jaleco Collection
    "BM2": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Momotarou Densetsu G Gold Deck wo Tsukure!
    "AMM": Savetype.SRAM_256K               , // SRAM_V110       Momotarou Matsuri
    "BUM": Savetype.NONE                    , // NONE            Monopoly
    "AM8": Savetype.EEPROM_4k               , // EEPROM_V122     Monster Force
    "ANF": Savetype.SRAM_256K               , // SRAM_V102       Monster Gate
    "A6G": Savetype.SRAM_256K               , // SRAM_V102       Monster Gate - Ooinaru Dungeon - Fuuin no Orb
    "AMN": Savetype.SRAM_256K               , // SRAM_V110       Monster Guardians
    "BQ7": Savetype.EEPROM_4k               , // EEPROM_V124     Monster House
    "AJA": Savetype.SRAM_256K               , // SRAM_V112       Monster Jam - Maximum Destruction
    "AA4": Savetype.SRAM_256K               , // SRAM_V112       Monster Maker 4 - Flash Card
    "AA5": Savetype.SRAM_256K               , // SRAM_V112       Monster Maker 4 - Killer Dice
    "AMF": Savetype.SRAM_256K               , // SRAM_V102       Monster Rancher Advance
    "A2Q": Savetype.SRAM_256K               , // SRAM_V102       Monster Rancher Advance 2
    "A3N": Savetype.SRAM_256K               , // SRAM_V103       Monster Summoner
    "BMT": Savetype.EEPROM_4k               , // EEPROM_V120     Monster Truck Madness
    "BMC": Savetype.NONE                    , // NONE            Monster Trucks
    "BYM": Savetype.NONE                    , // NONE            Monster Trucks Mayhem
    "A4B": Savetype.NONE                    , // NONE            Monster! Bass Fishing
    "AMX": Savetype.NONE                    , // NONE            Monsters, Inc.
    "AU3": Savetype.EEPROM_4k               , // EEPROM_V122     Moorhen 3 - The Chicken Chase!
    "AMS": Savetype.SRAM_256K               , // SRAM_V112       Morita Shougi Advance
    "AXD": Savetype.EEPROM_4k               , // EEPROM_V122     Mortal Kombat - Deadly Alliance
    "AW4": Savetype.EEPROM_4k               , // EEPROM_V122     Mortal Kombat - Tournament Edition
    "AM5": Savetype.NONE                    , // NONE            Mortal Kombat Advance
    "A2U": Savetype.SRAM_256K               , // SRAM_V112       Mother 1+2
    "A3U": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Mother 3
    "AM4": Savetype.NONE                    , // NONE            Moto GP
    "A9M": Savetype.SRAM_256K               , // SRAM_V113       Moto Racer Advance
    "AMR": Savetype.EEPROM_4k               , // EEPROM_V122     Motocross Maniacs Advance
    "BR2": Savetype.SRAM_256K               , // SRAM_V103       Mr. Driller 2
    "AD2": Savetype.SRAM_256K               , // SRAM_V100       Mr. Driller 2
    "AD5": Savetype.SRAM_256K               , // SRAM_V102       Mr. Driller A - Fushigi na Pacteria
    "AZR": Savetype.NONE                    , // NONE            Mr. Nutz
    "BPC": Savetype.EEPROM_4k               , // EEPROM_V124     Ms. Pac-Man - Maze Madness
    "B6P": Savetype.EEPROM_4k               , // EEPROM_V124     Ms. Pac-Man - Maze Madness + Pac-Man World
    "BML": Savetype.EEPROM_4k               , // EEPROM_V122     Mucha Lucha - Mascaritas of the Lost Code
    "AG6": Savetype.SRAM_256K               , // SRAM_V102       Mugenborg
    "AMW": Savetype.EEPROM_4k               , // EEPROM_V122     Muppet Pinball Mayhem
    "AMU": Savetype.SRAM_256K               , // SRAM_V112       Mutsu - Water Looper Mutsu
    "A2X": Savetype.NONE                    , // NONE            MX 2002 - Featuring Ricky Carmichael
    "BFR": Savetype.EEPROM_8k               , // EEPROM_V126     My Animal Centre in Africa
    "BL6": Savetype.NONE                    , // NONE            My Little Pony - Crystal Princess - The Runaway Rainbow
    "BQT": Savetype.EEPROM_4k_alt           , // EEPROM_V124     My Pet Hotel
    "AKP": Savetype.SRAM_256K               , // SRAM_V112       Nakayoshi Mahjong - Kaburiichi
    "AH7": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Nakayoshi Pet Advance Series 1 - Kawaii Hamster
    "AI7": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Nakayoshi Pet Advance Series 2 - Kawaii Koinu
    "BKI": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Nakayoshi Pet Advance Series 4 - Kawaii Koinu Mini - Wankoto Asobou!! Kogata-ken
    "AHV": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Nakayoshi Youchien - Sukoyaka Enji Ikusei Game
    "ANM": Savetype.NONE                    , // NONE            Namco Museum
    "B5N": Savetype.NONE                    , // NONE            Namco Museum - 50th Anniversary
    "AND": Savetype.NONE                    , // NONE            Nancy Drew - Message in a Haunted Mansion
    "ANP": Savetype.SRAM_256K               , // SRAM_V110       Napoleon
    "AYR": Savetype.SRAM_256K               , // SRAM_V112       Narikiri Jockey Game - Yuushun Rhapsody
    "AUE": Savetype.SRAM_256K               , // SRAM_V103       Naruto - Konoha Senki
    "A7A": Savetype.EEPROM_4k               , // EEPROM_V124     Naruto - Ninja Council
    "BN2": Savetype.SRAM_256K               , // SRAM_V113       Naruto Ninja Council 2
    "BNR": Savetype.SRAM_256K               , // SRAM_V113       Naruto RPG - Uketsugareshi Hi no Ishi
    "ANH": Savetype.EEPROM_4k               , // EEPROM_V120     NASCAR Heat 2002
    "AN2": Savetype.Flash_512k_SST          , // FLASH_V126      Natural 2 - Duo
    "ABN": Savetype.NONE                    , // NONE            NBA Jam 2002
    "BNW": Savetype.EEPROM_4k               , // EEPROM_V124     Need for Speed - Most Wanted
    "AZF": Savetype.EEPROM_4k               , // EEPROM_V124     Need for Speed - Porsche Unleashed
    "BNS": Savetype.EEPROM_4k               , // EEPROM_V124     Need for Speed - Underground
    "BNF": Savetype.EEPROM_4k               , // EEPROM_V124     Need for Speed - Underground 2
    "BN7": Savetype.EEPROM_4k               , // EEPROM_V124     Need for Speed Carbon - Own the City
    "ABZ": Savetype.NONE                    , // NONE            NFL Blitz 20-02
    "ANK": Savetype.NONE                    , // NONE            NFL Blitz 20-03
    "ATX": Savetype.EEPROM_4k               , // EEPROM_V122     NGT - Next Generation Tennis
    "ANL": Savetype.EEPROM_4k_alt           , // EEPROM_V122     NHL 2002
    "AN4": Savetype.EEPROM_4k               , // EEPROM_V122     NHL Hitz 20-03
    "BUJ": Savetype.NONE                    , // NONE            Nicktoons - Attack of the Toybots
    "BNV": Savetype.EEPROM_4k               , // EEPROM_V124     Nicktoons - Battle for Volcano Island
    "BCC": Savetype.EEPROM_4k               , // EEPROM_V124     Nicktoons - Freeze Frame Frenzy
    "ANQ": Savetype.EEPROM_4k               , // EEPROM_V122     Nicktoons Racing
    "BNU": Savetype.NONE                    , // NONE            Nicktoons Unite!
    "ANX": Savetype.EEPROM_4k               , // EEPROM_V122     Ninja Five-O
    "ANT": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Nippon Pro Mahjong Renmei Kounin - Tetsuman Advance
    "AGP": Savetype.NONE                    , // NONE            No Rules - Get Phat
    "ANO": Savetype.SRAM_256K               , // SRAM_V102       Nobunaga Ibun
    "ANB": Savetype.Flash_512k_SST          , // FLASH_V125      Nobunaga no Yabou
    "BNK": Savetype.NONE                    , // NONE            Noddy - A day in Toyland
    "BKR": Savetype.EEPROM_4k               , // EEPROM_V124     Nonono Puzzle Chailien
    "BNY": Savetype.EEPROM_4k               , // EEPROM_V124     Nyan Nyan Nyanko no Nyan Collection
    "BO2": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Ochainu no Bouken Jima
    "BIK": Savetype.EEPROM_8k               , // EEPROM_V124     Ochainuken Kururin
    "BDR": Savetype.EEPROM_4k               , // EEPROM_V124     Ochaken no Heya
    "BCU": Savetype.EEPROM_4k               , // EEPROM_V124     Ochaken no Yumebouken
    "BOD": Savetype.NONE                    , // NONE            Oddworld - Munch's Oddysee
    "A87": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Ohanaya-San Monogatari GBA
    "BOJ": Savetype.EEPROM_4k               , // EEPROM_V122     Ojarumaru - Gekkouchou Sanpo de Ojaru
    "AOK": Savetype.SRAM_256K               , // SRAM_V112       Okumanchouja Game - Nottori Daisakusen!
    "BON": Savetype.EEPROM_4k               , // EEPROM_V124     One Piece
    "BIP": Savetype.EEPROM_4k_alt           , // EEPROM_V124     One Piece - Dragon Dream
    "B08": Savetype.EEPROM_4k_alt           , // EEPROM_V124     One Piece - Going Baseball
    "BO8": Savetype.EEPROM_4k_alt           , // EEPROM_V124     One Piece - Going Baseball Haejeok Yaku
    "AUS": Savetype.SRAM_256K               , // SRAM_V112       One Piece - Mezase! King of Berries
    "AO7": Savetype.SRAM_256K               , // SRAM_V112       One Piece - Nanatsu Shima no Daihihou
    "A6O": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Onimusha Tactics
    "BIT": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Onmyou Taisenki Zeroshik
    "BOA": Savetype.EEPROM_4k               , // EEPROM_V124     Open Season
    "BAA": Savetype.NONE                    , // NONE            Operation Armored Liberty
    "AOR": Savetype.SRAM_256K               , // SRAM_V112       Oriental Blue - Ao no Tengai
    "AIC": Savetype.Flash_512k_SST          , // FLASH_V126      Oshaberi Inko Club
    "AOP": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Oshare Princess
    "AO2": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Oshare Princess 2
    "BO3": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Oshare Princess 3
    "BO5": Savetype.EEPROM_4k               , // EEPROM_V124     Oshare Princess 5
    "A5S": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Oshare Wanko
    "BOF": Savetype.NONE                    , // NONE            Ottifanten Pinball
    "BH5": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Over the Hedge
    "BH7": Savetype.EEPROM_4k               , // EEPROM_V124     Over the Hedge - Hammy Goes Nuts
    "BOZ": Savetype.NONE                    , // NONE            Ozzy & Drix
    "APC": Savetype.NONE                    , // NONE            Pac-Man Collection
    "BP8": Savetype.NONE                    , // NONE            Pac-Man Pinball Advance
    "BPA": Savetype.EEPROM_4k               , // EEPROM_V124     Pac-Man World
    "B2C": Savetype.NONE                    , // NONE            Pac-Man World 2
    "B6B": Savetype.NONE                    , // NONE            Paperboy - Rampage
    "BBQ": Savetype.SRAM_256K               , // SRAM_V113       Pawa Poke Dash
    "BUR": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Paws & Claws - Pet Resort
    "BPK": Savetype.EEPROM_4k               , // EEPROM_V124     Payback
    "BPZ": Savetype.EEPROM_4k               , // EEPROM_V122     Pazunin - Uminin No Puzzle de Nimu
    "APP": Savetype.NONE                    , // NONE            Peter Pan - Return to Neverland
    "BPT": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Peter Pan - The Motion Picture Event
    "AJH": Savetype.SRAM_256K               , // SRAM_V113       Petz - Hamsterz Life 2
    "BNB": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Petz Vet
    "BPV": Savetype.EEPROM_8k               , // EEPROM_V124     Pferd & Pony - Mein Pferdehof
    "APX": Savetype.EEPROM_4k               , // EEPROM_V122     Phalanx - The Enforce Fighter A-144
    "AYC": Savetype.EEPROM_4k_alt           , // EEPROM_V120     Phantasy Star Collection
    "BFX": Savetype.EEPROM_4k               , // EEPROM_V124     Phil of the Future
    "BP3": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Pia Carrot he Youkoso!! 3.3
    "A9N": Savetype.NONE                    , // NONE            Piglet's Big Game
    "BPN": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Pika Pika Nurse Monogatari - Nurse Ikusei Game
    "APZ": Savetype.EEPROM_4k               , // EEPROM_V122     Pinball Advance
    "APL": Savetype.NONE                    , // NONE            Pinball Challenge Deluxe
    "A2T": Savetype.NONE                    , // NONE            Pinball Tycoon
    "APE": Savetype.NONE                    , // NONE            Pink Panther - Pinkadelic Pursuit
    "AP7": Savetype.NONE                    , // NONE            Pink Panther - Pinkadelic Pursuit
    "API": Savetype.NONE                    , // NONE            Pinky and the Brain - The Masterplan
    "APN": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Pinky Monkey Town
    "APB": Savetype.SRAM_256K               , // SRAM_V111       Pinobee - Wings of Adventure
    "AP6": Savetype.EEPROM_4k               , // EEPROM_V122     Pinobee & Phoebee
    "B8Q": Savetype.EEPROM_4k               , // EEPROM_V124     Pirates of the Caribbean - Dead Man's Chest
    "A8Q": Savetype.NONE                    , // NONE            Pirates of the Caribbean - The Curse of the Black Pearl
    "BPH": Savetype.EEPROM_4k               , // EEPROM_V120     Pitfall - The Lost Expedition
    "APF": Savetype.NONE                    , // NONE            Pitfall - The Mayan Adventure
    "BQ9": Savetype.EEPROM_4k               , // EEPROM_V124     Pixeline i Pixieland
    "APM": Savetype.NONE                    , // NONE            Planet Monsters
    "AYN": Savetype.NONE                    , // NONE            Planet of the Apes
    "ASH": Savetype.SRAM_256K               , // SRAM_V110       Play Novel - Silent Hill
    "BTD": Savetype.EEPROM_4k               , // EEPROM_V124     Pocket Dogs
    "AP9": Savetype.SRAM_256K               , // SRAM_V102       Pocket Music
    "BPJ": Savetype.EEPROM_4k               , // EEPROM_V124     Pocket Professor - Kwik Notes Vol. 1
    "APK": Savetype.NONE                    , // NONE            Pocky & Rocky with Becky
    "BPE": Savetype.Flash_1M_Macronix_RTC   , // FLASH_V103      Pokemon - Emerald Version
    "BPR": Savetype.Flash_1M_Macronix_RTC   , // FLASH_V103      Pokemon - Fire Red Version
    "BPG": Savetype.Flash_1M_Macronix_RTC   , // FLASH_V103      Pokemon - Leaf Green Version
    "AXV": Savetype.Flash_1M_Macronix_RTC   , // FLASH_V103      Pokemon - Ruby Version
    "AXP": Savetype.Flash_1M_Macronix_RTC   , // FLASH_V103      Pokemon - Sapphire Version
    "B24": Savetype.Flash_1M_Macronix       , // FLASH_V102      Pokemon Mystery Dungeon - Red Rescue Team
    "BPP": Savetype.SRAM_256K               , // SRAM_V102       Pokemon Pinball - Ruby & Sapphire
    "BII": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Polarium Advance
    "B3F": Savetype.NONE                    , // NONE            Polly Pocket!
    "AOT": Savetype.NONE                    , // NONE            Polly! Pocket - Super Splash Island
    "APO": Savetype.NONE                    , // NONE            Popeye - Rush for Spinach
    "BRO": Savetype.NONE                    , // NONE            Postman Pat and the Greendale Rocket
    "B8P": Savetype.SRAM_256K               , // SRAM_V112       Power Pro Kun Pocket 1&2
    "AP3": Savetype.SRAM_256K               , // SRAM_V110       Power Pro Kun Pocket 3
    "AP4": Savetype.SRAM_256K               , // SRAM_V112       Power Pro Kun Pocket 4
    "A5P": Savetype.SRAM_256K               , // SRAM_V112       Power Pro Kun Pocket 5
    "BP6": Savetype.SRAM_256K               , // SRAM_V112       Power Pro Kun Pocket 6
    "BP7": Savetype.SRAM_256K               , // SRAM_V113       Power Pro Kun Pocket 7
    "BPO": Savetype.NONE                    , // NONE            Power Rangers - Dino Thunder
    "BPW": Savetype.NONE                    , // NONE            Power Rangers - Ninja Storm
    "BRD": Savetype.NONE                    , // NONE            Power Rangers - S.P.D.
    "APR": Savetype.NONE                    , // NONE            Power Rangers - Time Force
    "APW": Savetype.NONE                    , // NONE            Power Rangers - Wild Force
    "APH": Savetype.NONE                    , // NONE            Prehistorik Man
    "BAQ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Premier Action Soccer
    "BPM": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Premier Manager 2003-04
    "BP4": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Premier Manager 2004 - 2005
    "BP5": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Premier Manager 2005 - 2006
    "BPY": Savetype.EEPROM_4k               , // EEPROM_V122     Prince of Persia - The Sands of Time
    "B2Q": Savetype.EEPROM_4k               , // EEPROM_V124     Prince of Persia - The Sands of Time + Tomb Raider - The Prophecy
    "BNP": Savetype.NONE                    , // NONE            Princess Natasha - Student Secret Agent
    "B2O": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Pro Mahjong - Tsuwamono GBA
    "ALM": Savetype.SRAM_256K               , // SRAM_V112       Pro Yakyuu Team wo Tsukurou! Advance
    "APU": Savetype.EEPROM_4k_alt           , // EEPROM_V122     PukuPuku Tennen Kairanban
    "BPQ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     PukuPuku Tennen Kairanban - Koi no Cupid Daisakusen
    "B3P": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Pukupuku Tennen Kairanban Youkoso Illusion Land
    "APG": Savetype.NONE                    , // NONE            Punch King - Arcade Boxing
    "BYX": Savetype.EEPROM_4k               , // EEPROM_V124     Puppy Luv - Spa and Resort
    "APY": Savetype.EEPROM_4k               , // EEPROM_V122     Puyo Pop
    "BPF": Savetype.EEPROM_4k               , // EEPROM_V124     Puyo Pop Fever
    "AEH": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Puzzle & Tantei Collection
    "BPB": Savetype.SRAM_256K               , // SRAM_V113       Pyuu to Fuku! Jaguar - Byo to Deru! Megane Kun
    "BQD": Savetype.NONE                    , // NONE            Quad Desert Fury
    "BRW": Savetype.NONE                    , // NONE            Racing Fever
    "BRA": Savetype.EEPROM_4k               , // EEPROM_V124     Racing Gears Advance
    "ARX": Savetype.NONE                    , // NONE            Rampage - Puzzle Attack
    "BRF": Savetype.EEPROM_4k               , // EEPROM_V124     Rapala Pro Fishing
    "BNL": Savetype.NONE                    , // NONE            Ratatouille
    "BRM": Savetype.SRAM_256K               , // SRAM_V113       Rave Master - Special Attack Force
    "BX5": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Rayman - 10th Anniversary
    "BRY": Savetype.EEPROM_4k               , // EEPROM_V124     Rayman - Hoodlum's Revenge
    "BQ3": Savetype.EEPROM_4k               , // EEPROM_V124     Rayman - Raving Rabbids
    "AYZ": Savetype.EEPROM_4k               , // EEPROM_V122     Rayman 3
    "ARY": Savetype.EEPROM_4k               , // EEPROM_V111     Rayman Advance
    "ARF": Savetype.NONE                    , // NONE            Razor Freestyle Scooter
    "AR2": Savetype.NONE                    , // NONE            Ready 2 Rumble Boxing - Round 2
    "BRL": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Rebelstar - Tactical Command
    "ARH": Savetype.SRAM_256K               , // SRAM_V112       Recca no Honoo - The Game
    "AR9": Savetype.NONE                    , // NONE            Reign of Fire
    "BR9": Savetype.EEPROM_4k               , // EEPROM_V124     Relaxuma na Mainichi
    "AQH": Savetype.NONE                    , // NONE            Rescue Heroes - Billy Blazes!
    "BRI": Savetype.SRAM_256K               , // SRAM_V110       Rhythm Tengoku
    "B66": Savetype.NONE                    , // NONE            Risk - Battleship - Clue
    "BDT": Savetype.EEPROM_4k_alt           , // EEPROM_V124     River City Ransom EX
    "BRE": Savetype.SRAM_256K               , // SRAM_V103       Riviera - The Promised Land
    "A9R": Savetype.NONE                    , // NONE            Road Rash - Jailbreak
    "ACV": Savetype.Flash_512k_SST          , // FLASH_V126      Robopon 2 - Cross Version
    "ARP": Savetype.Flash_512k_SST          , // FLASH_V126      Robopon 2 - Ring Version
    "ARU": Savetype.EEPROM_4k               , // EEPROM_V122     Robot Wars - Advanced Destruction
    "ARW": Savetype.EEPROM_4k               , // EEPROM_V122     Robot Wars - Advanced Destruction
    "ARS": Savetype.EEPROM_4k               , // EEPROM_V122     Robot Wars - Extreme Destruction
    "ARB": Savetype.EEPROM_4k               , // EEPROM_V122     Robotech - The Macross Saga
    "BRT": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Robots
    "BR7": Savetype.NONE                    , // NONE            Rock 'Em Sock 'Em Robots
    "A4R": Savetype.EEPROM_4k               , // EEPROM_V122     Rock N' Roll Racing
    "AR4": Savetype.NONE                    , // NONE            Rocket Power - Beach Bandits
    "ARK": Savetype.NONE                    , // NONE            Rocket Power - Dream Scheme
    "AZZ": Savetype.NONE                    , // NONE            Rocket Power - Zero Gravity Zone
    "AFC": Savetype.EEPROM_4k_alt           , // EEPROM_V122     RockMan & Forte
    "BR4": Savetype.Flash_512k_Panasonic_RTC, // FLASH_V131      Rockman EXE 4.5 - Real Operation
    "ARZ": Savetype.SRAM_256K               , // SRAM_V112       RockMan Zero
    "AR8": Savetype.EEPROM_4k               , // EEPROM_V122     Rocky
    "ARO": Savetype.EEPROM_4k               , // EEPROM_V122     Rocky
    "A8T": Savetype.Flash_512k_Panasonic    , // FLASH_V130      RPG Tsukuru Advance
    "BR3": Savetype.NONE                    , // NONE            R-Type III
    "ARG": Savetype.NONE                    , // NONE            Rugrats - Castle Capers
    "A5W": Savetype.NONE                    , // NONE            Rugrats - Go Wild
    "AR5": Savetype.NONE                    , // NONE            Rugrats - I Gotta Go Party
    "AWU": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Sabre Wulf
    "A3B": Savetype.NONE                    , // NONE            Sabrina - The Teenage Witch - Potion Commotion
    "ASM": Savetype.SRAM_256K               , // SRAM_V112       Saibara Rieko no Dendou Mahjong
    "ACL": Savetype.SRAM_256K               , // SRAM_V112       Sakura Momoko no UkiUki Carnival
    "AS5": Savetype.EEPROM_4k               , // EEPROM_V121     Salt Lake 2002
    "AWG": Savetype.EEPROM_4k               , // EEPROM_V121     Salt Lake 2002
    "AOS": Savetype.EEPROM_4k               , // EEPROM_V124     Samurai Deeper Kyo
    "AEC": Savetype.SRAM_256K               , // SRAM_V102       Samurai Evolution - Oukoku Geist
    "AJT": Savetype.EEPROM_4k               , // EEPROM_V122     Samurai Jack - The Amulet of Time
    "ASX": Savetype.Flash_512k_SST          , // FLASH_V126      San Goku Shi
    "B3E": Savetype.Flash_512k_Panasonic    , // FLASH_V131      San Goku Shi Eiketsuden
    "B3Q": Savetype.Flash_512k_Panasonic    , // FLASH_V131      San Goku Shi Koumeiden
    "A85": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Sanrio Puroland All Characters
    "ASN": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Sansara Naga 1x2
    "AXX": Savetype.EEPROM_4k               , // EEPROM_V122     Santa Claus Jr. Advance
    "AUZ": Savetype.NONE                    , // NONE            Santa Claus Saves the Earth
    "A57": Savetype.SRAM_256K               , // SRAM_V102       Scan Hunter - Sennen Kaigyo wo Oe!
    "AP8": Savetype.EEPROM_4k               , // EEPROM_V122     Scooby-Doo - The Motion Picture
    "BMU": Savetype.NONE                    , // NONE            Scooby-Doo 2 - Monsters Unleashed
    "ASD": Savetype.NONE                    , // NONE            Scooby-Doo and the Cyber Chase
    "BMM": Savetype.EEPROM_4k               , // EEPROM_V122     Scooby-Doo! - Mystery Mayhem
    "B25": Savetype.NONE                    , // NONE            Scooby-Doo! - Unmasked
    "AQB": Savetype.SRAM_256K               , // SRAM_V112       Scrabble
    "BLA": Savetype.NONE                    , // NONE            Scrabble Blast!
    "BHV": Savetype.EEPROM_4k               , // EEPROM_V124     Scurge - Hive
    "BGE": Savetype.EEPROM_4k               , // EEPROM_V124     SD Gundam Force
    "BG4": Savetype.EEPROM_4k               , // EEPROM_V124     SD Gundam Force
    "BGA": Savetype.EEPROM_4k_alt           , // EEPROM_V124     SD Gundam G Generation
    "ALJ": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Sea Trader - Rise of Taipan
    "AAH": Savetype.NONE                    , // NONE            Secret Agent Barbie - Royal Jewels Mission
    "AYP": Savetype.NONE                    , // NONE            Sega Arcade Gallery
    "AYL": Savetype.SRAM_256K               , // SRAM_V102       Sega Rally Championship
    "A3P": Savetype.NONE                    , // NONE            Sega Smash Pack
    "A7G": Savetype.SRAM_256K               , // SRAM_V112       Sengoku Kakumei Gaiden
    "BKA": Savetype.Flash_1M_Macronix       , // FLASH_V102      Sennen Kazoku
    "BSY": Savetype.SRAM_256K               , // SRAM_V113       Sentouin - Yamada Hajime
    "AEN": Savetype.NONE                    , // NONE            Serious Sam Advance
    "BHL": Savetype.SRAM_256K               , // SRAM_V103       Shaman King - Legacy of the Spirits - Soaring Hawk
    "BWS": Savetype.SRAM_256K               , // SRAM_V103       Shaman King - Legacy of the Spirits - Sprinting Wolf
    "BSO": Savetype.SRAM_256K               , // SRAM_V113       Shaman King - Master of Spirits
    "AKA": Savetype.SRAM_256K               , // SRAM_V112       Shaman King Card Game - Chou Senjiryakketsu 2
    "AL3": Savetype.SRAM_256K               , // SRAM_V112       Shaman King Card Game - Chou Senjiryakketsu 3
    "BBA": Savetype.EEPROM_4k_alt           , // EEPROM_V126     Shamu's Deep Sea Adventures
    "BSH": Savetype.EEPROM_4k               , // EEPROM_V122     Shanghai
    "ASV": Savetype.EEPROM_4k               , // EEPROM_V122     Shanghai Advance
    "BSU": Savetype.EEPROM_4k               , // EEPROM_V124     Shark Tale
    "B9T": Savetype.EEPROM_4k               , // EEPROM_V124     Shark Tale
    "ASC": Savetype.NONE                    , // NONE            Shaun Palmer's Pro Snowboarder
    "AEP": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Sheep
    "A6R": Savetype.SRAM_256K               , // SRAM_V102       Shifting Gears - Road Trip
    "B4K": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Shikakui Atama wo Marukusuru Advance - Kanji Keisan
    "B4R": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Shikakui Atama wo Marukusuru Advance - Kokugo Sansu Rika Shakai
    "A64": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Shimura Ken no Baka Tonosama
    "U33": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Shin Bokura no Taiyou - Gyakushuu no Sabata
    "AAU": Savetype.SRAM_256K               , // SRAM_V112       Shin Megami Tensei
    "BDL": Savetype.SRAM_256K               , // SRAM_V113       Shin Megami Tensei - Devil Children Messiah Riser
    "A5T": Savetype.SRAM_256K               , // SRAM_V113       Shin Megami Tensei 2
    "BDH": Savetype.SRAM_256K               , // SRAM_V103       Shin Megami Tensei Devil Children - Honoo no Sho
    "BDY": Savetype.SRAM_256K               , // SRAM_V103       Shin Megami Tensei Devil Children - Koori no Sho
    "A8Z": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Shin Megami Tensei Devil Children - Puzzle de Call!
    "ARA": Savetype.SRAM_256K               , // SRAM_V112       Shin Nippon Pro Wrestling Toukon Retsuden Advance
    "BKV": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Shingata Medarot - Kabuto Version
    "BKU": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Shingata Medarot - Kuwagata Version
    "AF5": Savetype.SRAM_256K               , // SRAM_V113       Shining Force - Resurrection of the Dark Dragon
    "AHU": Savetype.Flash_512k_Panasonic    , // FLASH_V130      Shining Soul
    "AU2": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Shining Soul II
    "ANV": Savetype.SRAM_256K               , // SRAM_V102       Shiren Monsters - Netsal
    "B2M": Savetype.SRAM_256K               , // SRAM_V113       Shonen Jump's Shaman King - Master of Spirits 2
    "AH4": Savetype.EEPROM_4k               , // EEPROM_V122     Shrek - Hassle at the Castle
    "AOI": Savetype.EEPROM_4k               , // EEPROM_V122     Shrek - Reekin' Havoc
    "B4I": Savetype.EEPROM_4k               , // EEPROM_V124     Shrek - Smash n' Crash Racing
    "B4U": Savetype.EEPROM_4k               , // EEPROM_V124     Shrek - Super Slam
    "AS4": Savetype.EEPROM_4k               , // EEPROM_V122     Shrek - Swamp Kart Speedway
    "BSE": Savetype.EEPROM_4k               , // EEPROM_V124     Shrek 2
    "BSI": Savetype.EEPROM_4k               , // EEPROM_V124     Shrek 2 - Beg for Mercy
    "B3H": Savetype.EEPROM_4k               , // EEPROM_V124     Shrek the Third
    "B3G": Savetype.EEPROM_4k               , // EEPROM_V124     Sigma Star Saga
    "AIP": Savetype.EEPROM_4k               , // EEPROM_V122     Silent Scope
    "A7I": Savetype.SRAM_256K               , // SRAM_V112       Silk to Cotton
    "A5C": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Sim City 2000
    "AZK": Savetype.EEPROM_4k               , // EEPROM_V122     Simple 2960 Tomodachi Series Vol. 1 - The Table Game Collection
    "AZ9": Savetype.EEPROM_4k               , // EEPROM_V122     Simple 2960 Tomodachi Series Vol. 2 - The Block Kuzushi
    "BS3": Savetype.EEPROM_4k               , // EEPROM_V124     Simple 2960 Tomodachi Series Vol. 3 - The Itsudemo Puzzle
    "BS4": Savetype.EEPROM_4k               , // EEPROM_V124     Simple 2960 Tomodachi Series Vol. 4 - The Trump
    "AAJ": Savetype.SRAM_256K               , // SRAM_V113       Sin Kisekae Monogatari
    "A4P": Savetype.EEPROM_4k               , // EEPROM_V122     Sister Princess - RePure
    "BSD": Savetype.NONE                    , // NONE            Sitting Ducks
    "B4D": Savetype.NONE                    , // NONE            Sky Dancers - They Magically Fly!
    "A9K": Savetype.EEPROM_4k               , // EEPROM_V122     Slime Morimori Dragon Quest - Shougeki no Shippo Dan
    "ATB": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Slot! Pro 2 Advance - GoGo Juggler & New Tairyou
    "ASF": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Slot! Pro Advance - Takarabune & Ooedo Sakurafubuki 2
    "BSV": Savetype.NONE                    , // NONE            Smashing Drive
    "ASG": Savetype.NONE                    , // NONE            Smuggler's Run
    "AEA": Savetype.SRAM_256K               , // SRAM_V102       Snap Kid's
    "ASQ": Savetype.NONE                    , // NONE            Snood
    "B2V": Savetype.NONE                    , // NONE            Snood 2 - On Vacation
    "AK6": Savetype.NONE                    , // NONE            Soccer Kid
    "ALS": Savetype.EEPROM_4k               , // EEPROM_V122     Soccer Mania
    "ASO": Savetype.Flash_512k_SST          , // FLASH_V126      Sonic Advance
    "A2N": Savetype.Flash_512k_Panasonic    , // FLASH_V130      Sonic Advance 2
    "B3S": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Sonic Advance 3
    "BSB": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Sonic Battle
    "A3V": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Sonic Pinball Party
    "A86": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Sonic Pinball Party
    "BIJ": Savetype.EEPROM_4k               , // EEPROM_V124     Sonic The Hedgehog - Genesis
    "B67": Savetype.NONE                    , // NONE            Sorry! - Aggravation - Scrabble Junior
    "A5U": Savetype.EEPROM_4k               , // EEPROM_V122     Space Channel 5 - Ulala's Cosmic Attack
    "AJS": Savetype.SRAM_256K               , // SRAM_V111       Space Hexcite - Maetel Legend EX
    "AID": Savetype.EEPROM_4k               , // EEPROM_V120     Space Invaders
    "AS6": Savetype.EEPROM_4k               , // EEPROM_V120     Speedball 2 - Brutal Deluxe
    "AKX": Savetype.EEPROM_4k               , // EEPROM_V122     Spider-Man
    "BC9": Savetype.EEPROM_4k               , // EEPROM_V124     Spider-Man - Battle For New York
    "ASE": Savetype.NONE                    , // NONE            Spider-Man - Mysterio's Menace
    "BSP": Savetype.EEPROM_4k               , // EEPROM_V124     Spider-Man 2
    "BI3": Savetype.EEPROM_4k               , // EEPROM_V124     Spider-Man 3
    "AC6": Savetype.NONE                    , // NONE            Spirit - Stallion of the Cimarron
    "AWN": Savetype.NONE                    , // NONE            Spirit & Spells
    "BSQ": Savetype.NONE                    , // NONE            SpongeBob SquarePants - Battle for Bikini Bottom
    "BQ4": Savetype.EEPROM_4k               , // EEPROM_V124     SpongeBob SquarePants - Creature from the Krusty Krab
    "BQQ": Savetype.EEPROM_4k               , // EEPROM_V124     SpongeBob SquarePants - Lights, Camera, Pants!
    "AQ3": Savetype.NONE                    , // NONE            SpongeBob SquarePants - Revenge of the Flying Dutchman
    "ASP": Savetype.NONE                    , // NONE            SpongeBob SquarePants - SuperSponge
    "BZX": Savetype.NONE                    , // NONE            SpongeBob's Atlantis Squarepantis
    "AKB": Savetype.SRAM_256K               , // SRAM_V112       Sports Illustrated for Kids - Baseball
    "AKF": Savetype.SRAM_256K               , // SRAM_V112       Sports Illustrated for Kids - Football
    "B23": Savetype.EEPROM_4k               , // EEPROM_V124     Sportsman's Pack - Cabela's Big Game Hunter + Rapala Pro Fishing
    "B6A": Savetype.NONE                    , // NONE            Spy Hunter - Super Sprint
    "AV3": Savetype.EEPROM_4k               , // EEPROM_V122     Spy Kids 3-D - Game Over
    "A2K": Savetype.EEPROM_4k               , // EEPROM_V120     Spy Kids Challenger
    "BSS": Savetype.NONE                    , // NONE            Spy Muppets - License to Croak
    "AHN": Savetype.EEPROM_4k               , // EEPROM_V122     SpyHunter
    "AOW": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Spyro - Attack of the Rhynocs
    "ASY": Savetype.EEPROM_4k               , // EEPROM_V122     Spyro - Season of Ice
    "A2S": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Spyro 2 - Season of Flame
    "A4S": Savetype.EEPROM_4k               , // EEPROM_V122     Spyro Advance
    "BS8": Savetype.EEPROM_4k               , // EEPROM_V124     Spyro Advance - Wakuwaku Tomodachi
    "BST": Savetype.EEPROM_4k               , // EEPROM_V124     Spyro Orange - The Cortex Conspiracy
    "B8S": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Spyro Superpack - Season of Ice + Season of Flame
    "BSX": Savetype.EEPROM_4k               , // EEPROM_V122     SSX 3
    "AXY": Savetype.EEPROM_4k               , // EEPROM_V120     SSX Tricky
    "A9G": Savetype.NONE                    , // NONE            Stadium Games
    "BSW": Savetype.NONE                    , // NONE            Star Wars - Flight of the Falcon
    "ASW": Savetype.NONE                    , // NONE            Star Wars - Jedi Power Battles
    "A2W": Savetype.NONE                    , // NONE            Star Wars - The New Droid Army
    "AS2": Savetype.NONE                    , // NONE            Star Wars Episode II - Attack of the Clones
    "BE3": Savetype.EEPROM_4k               , // EEPROM_V124     Star Wars Episode III - Revenge of the Sith
    "BCK": Savetype.EEPROM_4k               , // EEPROM_V124     Star Wars Trilogy - Apprentice of the Force
    "AS8": Savetype.NONE                    , // NONE            Star X
    "AYH": Savetype.EEPROM_4k               , // EEPROM_V122     Starsky & Hutch
    "BKT": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Steel Empire
    "ATU": Savetype.EEPROM_4k               , // EEPROM_V122     Steven Gerrard's Total Soccer 2002
    "B35": Savetype.NONE                    , // NONE            Strawberry Shortcake - Summertime Adventure
    "BQW": Savetype.NONE                    , // NONE            Strawberry Shortcake - Summertime Adventure - Special Edition
    "B4T": Savetype.EEPROM_4k               , // EEPROM_V124     Strawberry Shortcake - Sweet Dreams
    "AZU": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Street Fighter Alpha 3 - Upper
    "A3Z": Savetype.EEPROM_4k               , // EEPROM_V122     Street Jam Basketball
    "BCZ": Savetype.EEPROM_4k               , // EEPROM_V124     Street Racing Syndicate
    "AFH": Savetype.NONE                    , // NONE            Strike Force Hydra
    "ASL": Savetype.NONE                    , // NONE            Stuart Little 2
    "AUX": Savetype.EEPROM_4k               , // EEPROM_V122     Stuntman
    "B4L": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Sugar Sugar Une - Heart Gaippai! Moegi Gakuen
    "AB4": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Summon Night - Swordcraft Story
    "BSK": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Summon Night - Swordcraft Story 2
    "B3C": Savetype.EEPROM_8k               , // EEPROM_V126     Summon Night Craft Sword Monogatari - Hajimari no Ishi
    "BG6": Savetype.NONE                    , // NONE            Super Army War
    "AVZ": Savetype.EEPROM_4k               , // EEPROM_V122     Super Bubble Pop
    "ABM": Savetype.NONE                    , // NONE            Super Bust-A-Move
    "BSA": Savetype.EEPROM_4k               , // EEPROM_V124     Super Chinese 1 - 2 Advance
    "BCL": Savetype.NONE                    , // NONE            Super Collapse! II
    "ADF": Savetype.SRAM_256K               , // SRAM_V110       Super Dodge Ball Advance
    "BDP": Savetype.EEPROM_4k               , // EEPROM_V122     Super Duper Sumos
    "AG5": Savetype.EEPROM_4k               , // EEPROM_V122     Super Ghouls 'N Ghosts
    "BF8": Savetype.NONE                    , // NONE            Super Hornet FA 18F
    "AMA": Savetype.EEPROM_4k               , // EEPROM_V120     Super Mario Advance
    "AMZ": Savetype.EEPROM_4k               , // EEPROM_V120     Super Mario Advance (Kiosk Demo)
    "AX4": Savetype.Flash_1M_Macronix       , // FLASH_V102      Super Mario Advance 4 - Super Mario Bros. 3
    "AA2": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Super Mario World - Super Mario Advance 2
    "ALU": Savetype.EEPROM_4k               , // EEPROM_V122     Super Monkey Ball Jr.
    "AZ8": Savetype.EEPROM_4k               , // EEPROM_V122     Super Puzzle Fighter II Turbo
    "BDM": Savetype.EEPROM_4k               , // EEPROM_V124     Super Real Mahjong Dousoukai
    "AOG": Savetype.Flash_512k_Panasonic    , // FLASH_V130      Super Robot Taisen - Original Generation
    "B2R": Savetype.Flash_512k_Panasonic    , // FLASH_V130      Super Robot Taisen - Original Generation 2
    "ASR": Savetype.Flash_512k_SST          , // FLASH_V125      Super Robot Taisen A
    "A6S": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Super Robot Taisen D
    "B6J": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Super Robot Taisen J
    "AJ9": Savetype.Flash_512k_SST          , // FLASH_V126      Super Robot Taisen R
    "AXR": Savetype.EEPROM_4k               , // EEPROM_V121     Super Street Fighter II Turbo - Revival
    "ASU": Savetype.NONE                    , // NONE            Superman - Countdown to Apokolips
    "BQX": Savetype.EEPROM_4k               , // EEPROM_V124     Superman Returns - Fortress of Solitude
    "BXU": Savetype.EEPROM_4k               , // EEPROM_V124     Surf's Up
    "ASK": Savetype.SRAM_256K               , // SRAM_V110       Sutakomi - Star Communicator
    "ABG": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Sweet Cookie Pie
    "AVS": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Sword of Mana
    "BSF": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Sylvania Family - Fashion Designer ni Naritai
    "A4L": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Sylvania Family 4 - Meguru Kisetsu no Tapestry
    "BS5": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Sylvanian Family - Yousei no Stick to Fushigi no Ki
    "ATO": Savetype.Flash_512k_SST          , // FLASH_V126      Tactics Ogre - The Knight of Lodis
    "BU6": Savetype.EEPROM_4k               , // EEPROM_V124     Taiketsu! Ultra Hero
    "BJW": Savetype.EEPROM_4k               , // EEPROM_V124     Tak - The Great Juju Challenge
    "BT9": Savetype.EEPROM_4k               , // EEPROM_V124     Tak 2 - The Staff of Dreams
    "BJU": Savetype.EEPROM_4k               , // EEPROM_V122     Tak and the Power of Juju
    "AN8": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Tales of Phantasia
    "AN9": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Tales of the World - Narikiri Dungeon 2
    "B3T": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Tales of the World - Narikiri Dungeon 3
    "A9P": Savetype.SRAM_256K               , // SRAM_V113       Tales of the World - Summoner's Lineage
    "AYM": Savetype.SRAM_256K               , // SRAM_V100       Tanbi Musou - Meine Liebe
    "ATA": Savetype.EEPROM_4k               , // EEPROM_V121     Tang Tang
    "BTI": Savetype.SRAM_256K               , // SRAM_V113       Tantei Gakuen Q - Kyukyoku Trick ni Idome!
    "BTQ": Savetype.SRAM_256K               , // SRAM_V113       Tantei Gakuen Q - Meitantei ha Kimi da!
    "BT3": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Tantei Jinguuji Saburou Shiroi Kage no Syoujyo
    "AJG": Savetype.EEPROM_4k               , // EEPROM_V122     Tarzan - Return to the Jungle
    "AXQ": Savetype.NONE                    , // NONE            Taxi 3
    "BBL": Savetype.EEPROM_4k               , // EEPROM_V124     Teen Titans
    "BZU": Savetype.EEPROM_4k               , // EEPROM_V124     Teen Titans 2
    "BNT": Savetype.EEPROM_4k               , // EEPROM_V122     Teenage Mutant Ninja Turtles
    "BT2": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Teenage Mutant Ninja Turtles 2 - Battlenexus
    "BT8": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Teenage Mutant Ninja Turtles Double Pack
    "ATK": Savetype.EEPROM_4k               , // EEPROM_V122     Tekken Advance
    "BTP": Savetype.NONE                    , // NONE            Ten Pin Alley 2
    "AT8": Savetype.EEPROM_4k               , // EEPROM_V120     Tennis Masters Series 2003
    "AVA": Savetype.SRAM_256K               , // SRAM_V112       Tennis no Ouji-sama - Aim at the Victory!
    "ATI": Savetype.Flash_512k_SST          , // FLASH_V126      Tennis no Ouji-sama - Genius Boys Academy
    "A9L": Savetype.SRAM_256K               , // SRAM_V102       Tennis no Ouji-sama 2003 - Cool Blue
    "A8R": Savetype.SRAM_256K               , // SRAM_V102       Tennis no Ouji-sama 2003 - Passion Red
    "B4G": Savetype.SRAM_256K               , // SRAM_V103       Tennis no Ouji-sama 2004 - Glorious Gold
    "B4S": Savetype.SRAM_256K               , // SRAM_V103       Tennis no Ouji-sama 2004 - Stylish Silver
    "AO3": Savetype.NONE                    , // NONE            Terminator 3 - Rise of the Machines
    "BTT": Savetype.EEPROM_4k               , // EEPROM_V124     Tetris Advance
    "ATW": Savetype.NONE                    , // NONE            Tetris Worlds
    "BXA": Savetype.NONE                    , // NONE            Texas Hold 'Em Poker
    "BRV": Savetype.EEPROM_4k               , // EEPROM_V124     That's So Raven
    "BZS": Savetype.EEPROM_4k               , // EEPROM_V124     Thats So Raven 2 - Supernatural Style
    "BJN": Savetype.NONE                    , // NONE            The Adventures of Jimmy Neutron - Boy Genius - Jet Fusion
    "AJX": Savetype.NONE                    , // NONE            The Adventures of Jimmy Neutron vs Jimmy Negatron
    "A7M": Savetype.NONE                    , // NONE            The Amazing Virtual Sea Monkeys
    "BUY": Savetype.EEPROM_4k               , // EEPROM_V124     The Ant Bully
    "BBI": Savetype.EEPROM_4k               , // EEPROM_V124     The Barbie Diaries - High School Mystery
    "BKF": Savetype.EEPROM_4k               , // EEPROM_V124     The Bee Game
    "BBO": Savetype.NONE                    , // NONE            The Berenstain Bears - And the Spooky Old Tree
    "BCT": Savetype.NONE                    , // NONE            The Cat in the Hat by Dr. Seuss
    "BCQ": Savetype.EEPROM_4k               , // EEPROM_V124     The Cheetah Girls
    "B2W": Savetype.EEPROM_4k               , // EEPROM_V124     The Chronicles of Narnia - The Lion, the Witch and the Wardrobe
    "AF6": Savetype.NONE                    , // NONE            The Fairly Odd Parents! - Breakin' da Rules
    "BFO": Savetype.NONE                    , // NONE            The Fairly Odd Parents! - Clash with the Anti-World
    "AFV": Savetype.NONE                    , // NONE            The Fairly Odd Parents! - Enter the Cleft
    "BF2": Savetype.NONE                    , // NONE            The Fairly Odd Parents! - Shadow Showdown
    "AFS": Savetype.NONE                    , // NONE            The Flintstones - Big Trouble in Bedrock
    "BIE": Savetype.EEPROM_4k               , // EEPROM_V124     The Grim - Adventures of Billy and Mandy
    "ALI": Savetype.NONE                    , // NONE            The Haunted Mansion
    "AH9": Savetype.EEPROM_4k               , // EEPROM_V122     The Hobbit
    "AHL": Savetype.EEPROM_4k               , // EEPROM_V122     The Incredible Hulk
    "BIC": Savetype.NONE                    , // NONE            The Incredibles
    "BIQ": Savetype.NONE                    , // NONE            The Incredibles - Rise of the Underminer
    "AIO": Savetype.EEPROM_4k               , // EEPROM_V120     The Invincible Iron Man
    "AJF": Savetype.NONE                    , // NONE            The Jungle Book
    "AKO": Savetype.EEPROM_4k               , // EEPROM_V122     The King of Fighters EX - Neo Blood
    "AEX": Savetype.EEPROM_4k               , // EEPROM_V122     The King of Fighters EX2 - Howling Blood
    "BAK": Savetype.NONE                    , // NONE            The Koala Brothers - Outback Adventures
    "ALA": Savetype.NONE                    , // NONE            The Land Before Time
    "BLO": Savetype.EEPROM_4k               , // EEPROM_V124     The Land Before Time - Into the Mysterious Beyond
    "B3Y": Savetype.EEPROM_4k_alt           , // EEPROM_V124     The Legend of Spyro - A New Beginning
    "BU7": Savetype.EEPROM_4k_alt           , // EEPROM_V126     The Legend of Spyro - The Eternal Night
    "AZL": Savetype.EEPROM_4k_alt           , // EEPROM_V122     The Legend of Zelda - A Link to the Past & Four Swords
    "BZM": Savetype.EEPROM_4k_alt           , // EEPROM_V124     The Legend of Zelda - The Minish Cap
    "BLK": Savetype.EEPROM_4k               , // EEPROM_V122     The Lion King 1.5
    "BN9": Savetype.EEPROM_4k               , // EEPROM_V124     The Little Mermaid - Magic in Two Kingdoms
    "ALO": Savetype.EEPROM_4k_alt           , // EEPROM_V122     The Lord of the Rings - The Fellowship of the Ring
    "BLR": Savetype.EEPROM_4k               , // EEPROM_V122     The Lord of the Rings - The Return of the King
    "B3A": Savetype.EEPROM_4k_alt           , // EEPROM_V124     The Lord of the Rings - The Third Age
    "ALP": Savetype.EEPROM_4k               , // EEPROM_V122     The Lord of the Rings - The Two Towers
    "ALV": Savetype.EEPROM_4k               , // EEPROM_V122     The Lost Vikings
    "AUM": Savetype.NONE                    , // NONE            The Mummy
    "AZM": Savetype.NONE                    , // NONE            The Muppets - On With the Show!
    "APD": Savetype.EEPROM_4k               , // EEPROM_V122     The Pinball of the Dead
    "AZO": Savetype.EEPROM_4k               , // EEPROM_V122     The Pinball of the Dead
    "BPX": Savetype.EEPROM_4k               , // EEPROM_V124     The Polar Express
    "AP5": Savetype.EEPROM_4k               , // EEPROM_V122     The Powerpuff Girls - Him and Seek
    "APT": Savetype.EEPROM_4k               , // EEPROM_V122     The Powerpuff Girls - Mojo Jojo A-Go-Go
    "BD7": Savetype.EEPROM_4k               , // EEPROM_V124     The Proud Family
    "A3R": Savetype.NONE                    , // NONE            The Revenge of Shinobi
    "ARD": Savetype.NONE                    , // NONE            The Ripping Friends
    "B33": Savetype.EEPROM_4k               , // EEPROM_V124     The Santa Clause 3 - The Escape Clause
    "ASZ": Savetype.NONE                    , // NONE            The Scorpion King - Sword of Osiris
    "A4A": Savetype.NONE                    , // NONE            The Simpsons - Road Rage
    "B4P": Savetype.EEPROM_4k_alt           , // EEPROM_V124     The Sims
    "ASI": Savetype.EEPROM_4k_alt           , // EEPROM_V124     The Sims - Bustin' Out
    "B46": Savetype.Flash_512k_Panasonic    , // FLASH_V131      The Sims 2
    "B4O": Savetype.Flash_512k_Panasonic    , // FLASH_V131      The Sims 2 - Pets
    "A7S": Savetype.NONE                    , // NONE            The Smurfs - The Revenge of the Smurfs
    "BSN": Savetype.NONE                    , // NONE            The SpongeBob SquarePants Movie
    "BZC": Savetype.EEPROM_4k               , // EEPROM_V124     The Suite Life of Zack & Cody - Tipton Trouble
    "AA6": Savetype.EEPROM_4k               , // EEPROM_V122     The Sum of All Fears
    "A3T": Savetype.NONE                    , // NONE            The Three Stooges
    "BTR": Savetype.Flash_512k_Panasonic    , // FLASH_V131      The Tower SP
    "BOC": Savetype.Flash_512k_Panasonic    , // FLASH_V131      The Urbz - Sims in the City
    "BWL": Savetype.EEPROM_4k               , // EEPROM_V124     The Wild
    "AWT": Savetype.NONE                    , // NONE            The Wild Thornberrys - Chimp Chase
    "AWL": Savetype.NONE                    , // NONE            The Wild Thornberrys Movie
    "BTH": Savetype.NONE                    , // NONE            Thunder Alley
    "BTB": Savetype.NONE                    , // NONE            Thunderbirds
    "ATN": Savetype.NONE                    , // NONE            Thunderbirds - International Rescue
    "BTW": Savetype.EEPROM_4k               , // EEPROM_V122     Tiger Woods PGA Tour 2004
    "AT5": Savetype.EEPROM_4k               , // EEPROM_V122     Tiger Woods PGA Tour Golf
    "BNC": Savetype.EEPROM_4k               , // EEPROM_V124     Tim Burton's The Nightmare Before Christmas - The Pumpkin King
    "ATT": Savetype.NONE                    , // NONE            Tiny Toon Adventures - Scary Dreams
    "AWS": Savetype.NONE                    , // NONE            Tiny Toon Adventures - Wacky Stackers
    "ATV": Savetype.NONE                    , // NONE            Tir et But - Edition Champions du Monde
    "BTC": Savetype.NONE                    , // NONE            Titeuf - Mega-Compet
    "BEX": Savetype.EEPROM_4k               , // EEPROM_V124     TMNT
    "ATQ": Savetype.EEPROM_4k               , // EEPROM_V122     TOCA World Touring Cars
    "AF7": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Tokimeki Yume Series 1 - Ohanaya-san ni Narou!
    "BTF": Savetype.SRAM_256K               , // SRAM_V113       Tokyo Majin Gakuen - Fuju Houroku
    "BTZ": Savetype.EEPROM_4k               , // EEPROM_V124     Tokyo Xtreme Racer Advance
    "ATJ": Savetype.NONE                    , // NONE            Tom and Jerry - The Magic Ring
    "AIF": Savetype.NONE                    , // NONE            Tom and Jerry in Infurnal Escape
    "BJT": Savetype.NONE                    , // NONE            Tom and Jerry Tales
    "AR6": Savetype.EEPROM_4k               , // EEPROM_V122     Tom Clancy's Rainbow Six - Rogue Spear
    "AO4": Savetype.EEPROM_4k               , // EEPROM_V122     Tom Clancy's Splinter Cell
    "BSL": Savetype.EEPROM_4k               , // EEPROM_V124     Tom Clancy's Splinter Cell - Pandora Tomorrow
    "AGL": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Tomato Adventure
    "BL8": Savetype.EEPROM_4k               , // EEPROM_V126     Tomb Raider - Legend
    "AL9": Savetype.NONE                    , // NONE            Tomb Raider - The Prophecy
    "AUT": Savetype.NONE                    , // NONE            Tomb Raider - The Prophecy
    "BT7": Savetype.NONE                    , // NONE            Tonka - On the Job
    "BH9": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Tony Hawk's American Sk8land
    "BXS": Savetype.EEPROM_4k               , // EEPROM_V124     Tony Hawk's Downhill Jam
    "ATH": Savetype.EEPROM_4k               , // EEPROM_V111     Tony Hawk's Pro Skater 2
    "AT3": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Tony Hawk's Pro Skater 3
    "AT6": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Tony Hawk's Pro Skater 4
    "BTO": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Tony Hawk's Underground
    "B2T": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Tony Hawk's Underground 2
    "AT7": Savetype.NONE                    , // NONE            Tootuff - The Gagmachine
    "A2Y": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Top Gun - Combat Zones
    "ATG": Savetype.NONE                    , // NONE            Top Gun - Firestorm Advance
    "B27": Savetype.EEPROM_4k               , // EEPROM_V124     Top Spin 2
    "ATC": Savetype.EEPROM_4k               , // EEPROM_V120     TopGear GT Championship
    "BTG": Savetype.EEPROM_4k               , // EEPROM_V122     TopGear Rally
    "AYE": Savetype.EEPROM_4k               , // EEPROM_V122     TopGear Rally
    "BTU": Savetype.EEPROM_4k               , // EEPROM_V124     Totally Spies
    "B2L": Savetype.EEPROM_4k               , // EEPROM_V124     Totally Spies 2 - Undercover
    "A59": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Toukon Heat
    "ATR": Savetype.SRAM_256K               , // SRAM_V112       Toyrobo Force
    "AZQ": Savetype.NONE                    , // NONE            Treasure Planet
    "B9S": Savetype.EEPROM_4k               , // EEPROM_V124     Trick Star
    "BTJ": Savetype.EEPROM_4k               , // EEPROM_V124     Tringo
    "BT6": Savetype.EEPROM_4k               , // EEPROM_V124     Trollz - Hair Affair!
    "BTN": Savetype.EEPROM_4k               , // EEPROM_V124     Tron 2.0 - Killer App
    "AK3": Savetype.EEPROM_4k               , // EEPROM_V122     Turbo Turtle Adventure
    "AT4": Savetype.NONE                    , // NONE            Turok Evolution
    "ATM": Savetype.SRAM_256K               , // SRAM_V112       Tweety and the Magic Gems
    "AMJ": Savetype.SRAM_256K               , // SRAM_V110       Tweety no Hearty Party
    "BFV": Savetype.EEPROM_4k               , // EEPROM_V124     Twin Series 1 - Fashion Designer Monogatari + Kawaii Pet Game Gallery 2
    "BOP": Savetype.EEPROM_4k               , // EEPROM_V124     Twin Series 2 - Oshare Princess 4 + Renai Uranai Daisakusen
    "BQM": Savetype.EEPROM_4k               , // EEPROM_V124     Twin Series 3 - Konchuu Monster + Suchai Labyrinth
    "BHF": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Twin Series 4 - Ham Ham Monster EX + Fantasy Puzzle Hamster Monogatari
    "BMW": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Twin Series 5 - Wan Wan Meitantei EX + Mahou no Kuni no Keaki-Okusan Monogatari
    "BWN": Savetype.EEPROM_4k               , // EEPROM_V124     Twin Series 6 - Wan Nyon Idol Gakuen + Koinu Toissho Special
    "B2P": Savetype.EEPROM_4k               , // EEPROM_V124     Twin Series 7 - Twin Puzzle - Kisekae Wanko Ex + Puzzle Rainbow Magic 2
    "BTY": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Ty the Tasmanian Tiger 2 - Bush Rescue
    "BTV": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Ty the Tasmanian Tiger 3 - Night of the Quinkan
    "BUV": Savetype.SRAM_256K               , // SRAM_V113       Uchu no Stellvia
    "AUC": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Uchuu Daisakusen Choco Vader - Uchuu Kara no Shinryakusha
    "BUH": Savetype.EEPROM_4k               , // EEPROM_V124     Ueki no Housoku Shinki Sakuretsu! Nouryokumono Battle
    "AEW": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Ui-Ire - World Soccer Winning Eleven
    "BUZ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Ultimate Arcade Games
    "AVE": Savetype.EEPROM_4k               , // EEPROM_V122     Ultimate Beach Soccer
    "ABU": Savetype.EEPROM_4k               , // EEPROM_V122     Ultimate Brain Games
    "BUC": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Ultimate Card Games
    "AK2": Savetype.EEPROM_4k               , // EEPROM_V122     Ultimate Muscle - The Kinnikuman Legacy - The Path of the Superhero
    "BUA": Savetype.EEPROM_4k               , // EEPROM_V124     Ultimate Puzzle Games
    "BUL": Savetype.EEPROM_4k               , // EEPROM_V124     Ultimate Spider-Man
    "BUW": Savetype.NONE                    , // NONE            Ultimate Winter Games
    "BUT": Savetype.Flash_512k_Panasonic    , // FLASH_V131      Ultra Keibitai - Monster Attack
    "BU4": Savetype.NONE                    , // NONE            Unfabulous
    "BU5": Savetype.NONE                    , // NONE            Uno 52
    "BUI": Savetype.NONE                    , // NONE            Uno Freefall
    "AYI": Savetype.NONE                    , // NONE            Urban Yeti!
    "AVP": Savetype.NONE                    , // NONE            V.I.P.
    "BAN": Savetype.NONE                    , // NONE            Van Helsing
    "BRX": Savetype.SRAM_256K               , // SRAM_V103       Vattroller X
    "BZT": Savetype.EEPROM_4k               , // EEPROM_V124     VeggieTales - LarryBoy and the Bad Apple
    "AVT": Savetype.EEPROM_4k               , // EEPROM_V121     Virtua Tennis
    "AVK": Savetype.EEPROM_4k               , // EEPROM_V121     Virtual Kasparov
    "AVM": Savetype.EEPROM_4k               , // EEPROM_V122     V-Master Cross
    "AVR": Savetype.EEPROM_4k               , // EEPROM_V122     V-Rally 3
    "BWT": Savetype.EEPROM_4k               , // EEPROM_V124     W.i.t.c.h.
    "BSR": Savetype.EEPROM_4k               , // EEPROM_V122     Wade Hixton's Counter Punch
    "BMI": Savetype.SRAM_256K               , // SRAM_V113       Wagamama - Fairy Milmo de Pon! DokiDoki Memorial
    "BWP": Savetype.SRAM_256K               , // SRAM_V113       Wagamama Fairy Mirumo de Pon Nazo no Kagi to Shinjitsu no Tobir
    "BMY": Savetype.SRAM_256K               , // SRAM_V103       Wagamama Fairy Mirumo de Pon! - 8 Nin no Toki no Yousei
    "AWK": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Wagamama Fairy Mirumo de Pon! - Ougon Maracas no Densetsu
    "BMP": Savetype.SRAM_256K               , // SRAM_V103       Wagamama Fairy Mirumo de Pon! - Taisen Mahoudama
    "BWF": Savetype.SRAM_256K               , // SRAM_V113       Wagamama Fairy Mirumo de Pon! Yume no Kakera
    "AWD": Savetype.EEPROM_4k               , // EEPROM_V120     Wakeboarding Unleashed featuring Shaun Murray
    "BWD": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Wan Nyan Doubutsu Byouin
    "BWK": Savetype.EEPROM_4k               , // EEPROM_V124     Wanko Dekururi! Wankuru
    "BWX": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Wanko Mix Chiwanko World
    "BWM": Savetype.EEPROM_4k               , // EEPROM_V124     WanWan Meitantei
    "AWA": Savetype.SRAM_256K               , // SRAM_V112       Wario Land 4
    "RZW": Savetype.SRAM_256K               , // SRAM_V113       WarioWare Twisted!
    "AZW": Savetype.SRAM_256K               , // SRAM_V112       WarioWare, Inc. - Mega Microgames!
    "AW3": Savetype.EEPROM_4k               , // EEPROM_V122     Watashi no Makesalon
    "BWE": Savetype.EEPROM_4k               , // EEPROM_V124     Whac-A-Mole
    "A73": Savetype.SRAM_256K               , // SRAM_V113       Whistle! - Dai 37 Kai Tokyo-to Chuugakkou Sougou Taiiku Soccer Taikai
    "A55": Savetype.NONE                    , // NONE            Who Wants to Be a Millionaire
    "B55": Savetype.NONE                    , // NONE            Who Wants to Be a Millionaire - 2nd Edition
    "BWJ": Savetype.NONE                    , // NONE            Who Wants to Be a Millionaire - Junior
    "AW9": Savetype.EEPROM_4k               , // EEPROM_V122     Wing Commander - Prophecy
    "AWQ": Savetype.EEPROM_4k               , // EEPROM_V122     Wings
    "BWH": Savetype.NONE                    , // NONE            Winnie the Pooh's Rumbly Tumbly Adventure
    "BWZ": Savetype.EEPROM_4k               , // EEPROM_V124     Winnie the Pooh's Rumbly Tumbly Adventure + Rayman 3
    "AWP": Savetype.Flash_512k_Atmel        , // FLASH_V121      Winning Post for GameBoy Advance
    "BWY": Savetype.EEPROM_4k               , // EEPROM_V124     Winter Sports
    "BWI": Savetype.EEPROM_4k_alt           , // EEPROM_V124     WinX Club
    "BWV": Savetype.EEPROM_4k               , // EEPROM_V124     Winx Club - Quest For The Codex
    "AWZ": Savetype.SRAM_256K               , // SRAM_V102       Wizardry Summoner
    "AWO": Savetype.EEPROM_4k               , // EEPROM_V120     Wolfenstein 3D
    "AWW": Savetype.EEPROM_4k               , // EEPROM_V122     Woody Woodpecker in Crazy Castle 5
    "BB8": Savetype.EEPROM_4k               , // EEPROM_V124     Word Safari - The Friendship Totems
    "AAS": Savetype.EEPROM_4k_alt           , // EEPROM_V122     World Advance Soccer - Shouri heno Michi
    "BP9": Savetype.NONE                    , // NONE            World Championship Poker
    "B26": Savetype.EEPROM_4k_alt           , // EEPROM_V124     World Poker Tour
    "BWO": Savetype.EEPROM_4k_alt           , // EEPROM_V124     World Poker Tour
    "BWR": Savetype.NONE                    , // NONE            World Reborn
    "AWC": Savetype.NONE                    , // NONE            World Tennis Stars
    "AWB": Savetype.NONE                    , // NONE            Worms Blast
    "AWY": Savetype.NONE                    , // NONE            Worms World Party
    "ATE": Savetype.EEPROM_4k               , // EEPROM_V122     WTA Tour Tennis
    "ACI": Savetype.EEPROM_4k               , // EEPROM_V122     WTA Tour Tennis Pocket
    "AW8": Savetype.EEPROM_4k               , // EEPROM_V122     WWE - Road to WrestleMania X8
    "BWW": Savetype.EEPROM_4k               , // EEPROM_V124     WWE Survivor Series
    "AWF": Savetype.NONE                    , // NONE            WWF - Road to WrestleMania
    "AWV": Savetype.EEPROM_4k               , // EEPROM_V122     X2 - Wolverine's Revenge
    "AXI": Savetype.NONE                    , // NONE            X-bladez - Inline Skater
    "AXM": Savetype.EEPROM_4k               , // EEPROM_V121     X-Men - Reign of Apocalypse
    "B3X": Savetype.EEPROM_4k               , // EEPROM_V124     X-Men - The Official Game
    "BXM": Savetype.NONE                    , // NONE            XS Moto
    "AX3": Savetype.EEPROM_4k               , // EEPROM_V121     xXx
    "B64": Savetype.NONE                    , // NONE            Yars' Revenge - Pong - Asteroids
    "BYU": Savetype.EEPROM_8k               , // EEPROM_V126     Yggdra Union - We'll Never Fight Alone
    "BYV": Savetype.SRAM_256K               , // SRAM_V103       Yo-Gi-Oh! Double Pack 2 - Destiny Board Traveler + Dungeon Dice Monsters
    "KYG": Savetype.EEPROM_4k               , // EEPROM_V124     Yoshi Topsy-Turvy
    "A3A": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Yoshi's Island - Super Mario Advance 3
    "AFU": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Youkaidou
    "BYY": Savetype.EEPROM_4k               , // EEPROM_V122     Yu Yu Hakusho - Spirit Detective
    "BYD": Savetype.SRAM_256K               , // SRAM_V103       Yu-Gi-Oh! - Destiny Board Traveler
    "AY8": Savetype.SRAM_256K               , // SRAM_V102       Yu-Gi-Oh! - Reshef of Destruction
    "BY7": Savetype.SRAM_256K               , // SRAM_V113       Yu-Gi-Oh! 7 Trials to Glory - World Championship Tournament 2005
    "BYO": Savetype.SRAM_256K               , // SRAM_V113       Yu-Gi-Oh! Day Of The Duelist - World Championship Tournament 2005
    "BY2": Savetype.SRAM_256K               , // SRAM_V102       Yu-Gi-Oh! Double Pack
    "AY6": Savetype.SRAM_256K               , // SRAM_V112       Yu-Gi-Oh! Duel Monsters 6 Expert 2
    "BY3": Savetype.SRAM_256K               , // SRAM_V113       Yu-Gi-Oh! Duel Monsters Expert 3
    "BYI": Savetype.SRAM_256K               , // SRAM_V113       Yu-Gi-Oh! Duel Monsters International 2
    "AYD": Savetype.Flash_512k_SST          , // FLASH_V126      Yu-Gi-Oh! Dungeon Dice Monsters
    "BYG": Savetype.SRAM_256K               , // SRAM_V113       Yu-Gi-Oh! GX - Duel Academy
    "BYS": Savetype.SRAM_256K               , // SRAM_V103       Yu-Gi-Oh! Sugoroku no Sugoroku
    "AY5": Savetype.SRAM_256K               , // SRAM_V112       Yu-Gi-Oh! The Eternal Duelist Soul
    "AY7": Savetype.SRAM_256K               , // SRAM_V102       Yu-Gi-Oh! The Sacred Cards
    "BY6": Savetype.SRAM_256K               , // SRAM_V103       Yu-Gi-Oh! Ultimate Masters 2006
    "BYW": Savetype.SRAM_256K               , // SRAM_V113       Yu-Gi-Oh! World Championship Tournament 2004
    "AYW": Savetype.SRAM_256K               , // SRAM_V113       Yu-Gi-Oh! Worldwide Edition - Stairway to the Destined Duel
    "A4V": Savetype.SRAM_256K               , // SRAM_V102       Yuujou no Victory Goal 4v4 Arashi - Get the Goal!!
    "AUY": Savetype.EEPROM_4k               , // EEPROM_V122     Yuureiyashiki no Nijuuyojikan
    "BRG": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Yu-Yu-Hakusho - Tournament Tactics
    "AZP": Savetype.EEPROM_4k               , // EEPROM_V122     Zapper
    "A4G": Savetype.EEPROM_4k_alt           , // EEPROM_V124     ZatchBell! - Electric Arena
    "AGT": Savetype.Flash_512k_Atmel        , // FLASH_V121      Zen-Nippon GT Senshuken
    "A2Z": Savetype.Flash_512k_SST          , // FLASH_V126      Zen-Nippon Shounen Soccer Taikai 2 - Mezase Nippon-ichi!
    "AF3": Savetype.EEPROM_4k_alt           , // EEPROM_V122     Zero One
    "BZO": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Zero One SP
    "AZT": Savetype.Flash_512k_SST          , // FLASH_V124      Zero-Tours
    "BJ3": Savetype.SRAM_256K               , // SRAM_V113       Zettai Zetsumei - Dangerous Jiisan 3 Hateshinaki Mamonogatari
    "BZD": Savetype.SRAM_256K               , // SRAM_V113       Zettai Zetsumei Dangerous Jiisan - Shijou Saikyou no Togeza
    "BZG": Savetype.SRAM_256K               , // SRAM_V113       Zettai Zetsumei Dangerous Jiisan - Zettai Okujou Bai Orensu Kouchou
    "BZ2": Savetype.SRAM_256K               , // SRAM_V113       Zettai Zetsumei Den Chara Suji-Sa
    "AZD": Savetype.NONE                    , // NONE            Zidane Football Generation
    "BZY": Savetype.NONE                    , // NONE            Zoey 101
    "AZ2": Savetype.SRAM_256K               , // SRAM_V103       Zoids - Legacy
    "ATZ": Savetype.SRAM_256K               , // SRAM_V102       Zoids Saga
    "BZF": Savetype.SRAM_256K               , // SRAM_V103       Zoids Saga - Fuzors
    "AZE": Savetype.Flash_512k_SST          , // FLASH_V126      Zone of the Enders - The Fist of Mars
    "ANC": Savetype.EEPROM_4k               , // EEPROM_V122     ZooCube
    "BMZ": Savetype.EEPROM_4k_alt           , // EEPROM_V124     Zooo
]
