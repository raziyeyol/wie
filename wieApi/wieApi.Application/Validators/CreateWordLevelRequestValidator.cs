using FluentValidation;
using wieApi.Application.DTOs;

namespace wieApi.Application.Validators;

public class CreateWordLevelRequestValidator : AbstractValidator<CreateWordLevelRequest>
{
    public CreateWordLevelRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(100);

        RuleFor(x => x.YearBand)
            .NotEmpty()
            .MaximumLength(50);

        RuleFor(x => x.Difficulty)
            .NotEmpty()
            .MaximumLength(50);

        RuleFor(x => x.Description)
            .NotEmpty()
            .MaximumLength(500);

        RuleFor(x => x.Words)
            .NotEmpty()
            .WithMessage("At least one word is required")
            .Must(words => words.All(w => !string.IsNullOrWhiteSpace(w)))
            .WithMessage("Word entries cannot be empty");
    }
}
