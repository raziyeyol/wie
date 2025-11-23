using wieApi.Domain.Entities;

namespace wieApi.Infrastructure.Seed;

internal static class WordSeedData
{
    private static readonly IReadOnlyCollection<WordSeedDescriptor> Levels =
    [
        new WordSeedDescriptor(
            Name: "Year 1",
            Description: "Common exception words for Year 1 learners.",
            Words:
            [
                "today","said","says","are","were","was","his","has","you","your","they",
                "here","there","where","love","come","some","one","once","ask","friend",
                "school","put","push","pull","full","house","our"
            ]),
        new WordSeedDescriptor(
            Name: "Year 2",
            Description: "Common exception words for Year 2 learners.",
            Words:
            [
                "door","floor","poor","because","find","kind","mind","behind","child","children",
                "wild","climb","most","only","both","old","cold","gold","hold","told","every",
                "great","break","steak","pretty","beautiful","after","fast","last","past","father",
                "class","grass","pass","plant","path","bath","hour","move","prove","improve",
                "sure","sugar","eye","could","should","would","who","whole","any","many","clothes",
                "busy","people","water","again","half","money","Mr","Mrs","parents","Christmas",
                "everybody","even"
            ]),
        new WordSeedDescriptor(
            Name: "Year 3 & Year 4",
            Description: "Common exception words for Years 3 and 4.",
            Words:
            [
                "accident","accidentally","actual","actually","address","although","answer","appear","arrive",
                "believe","bicycle","breath","breathe","build","busy","business","calendar","caught","centre",
                "century","certain","circle","complete","consider","continue","decide","describe","different",
                "difficult","disappear","early","earth","eight","eighth","enough","exercise","experience",
                "experiment","extreme","famous","favourite","february","forward","forwards","fruit","grammar",
                "group","guard","guide","heard","heart","height","history","imagine","important","increase",
                "interest","island","knowledge","learn","length","library","material","medicine","mention",
                "minute","natural","naughty","notice","occasion","occasionally","often","opposite","ordinary",
                "particular","peculiar","perhaps","popular","position","possess","possession","possible",
                "potatoes","pressure","probably","promise","purpose","quarter","question","recent","regular",
                "reign","remember","sentence","separate","special","straight","strange","strength","suppose",
                "surprise","therefore","though","thought","through","various","weight","woman","women"
            ]),
        new WordSeedDescriptor(
            Name: "Year 5 & Year 6",
            Description: "Extended exception words for Years 5 and 6.",
            Words:
            [
                "accommodate","accompany","according","achieve","aggressive","amateur","ancient","apparent",
                "appreciate","attached","available","average","awkward","bargain","bruise","category",
                "cemetery","committee","communicate","community","competition","conscience","conscious",
                "controversy","convenience","correspond","criticise","curiosity","definite","desperate",
                "determined","develop","dictionary","disastrous","embarrass","environment","equip","equipped",
                "equipment","especially","exaggerate","excellent","existence","explanation","familiar","foreign",
                "forty","frequently","government","guarantee","harass","hindrance","identity","immediate",
                "immediately","individual","interfere","interrupt","language","leisure","lightning","marvellous",
                "mischievous","muscle","necessary","neighbour","nuisance","occupy","occur","opportunity",
                "parliament","persuade","physical","prejudice","privilege","profession","programme",
                "pronunciation","queue","recognise","recommend","relevant","restaurant","rhyme","rhythm",
                "sacrifice","secretary","shoulder","signature","sincere","sincerely","soldier","stomach",
                "sufficient","suggest","symbol","system","temperature","thorough","twelfth","variety",
                "vegetable","vehicle","yacht"
            ])
    ];

    public static IReadOnlyCollection<WordLevel> BuildLevels()
    {
        return Levels
            .Select(descriptor => new WordLevel
            {
                Name = descriptor.Name,
                Description = descriptor.Description,
                Words = descriptor.Words
                    .Select((word, index) => new Word
                    {
                        Text = word,
                        SortOrder = index + 1
                    })
                    .ToList()
            })
            .ToList();
    }

    private sealed record WordSeedDescriptor(
        string Name,
        string Description,
        IReadOnlyList<string> Words);
}
