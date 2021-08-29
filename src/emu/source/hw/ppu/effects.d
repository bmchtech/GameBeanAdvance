module hw.ppu.effects;

enum SpecialEffect {
    None               = 0,
    Alpha              = 1,
    BrightnessIncrease = 2,
    BrightnessDecrease = 3
}

enum SpecialEffectLayer {
    A,
    B,
    None
}