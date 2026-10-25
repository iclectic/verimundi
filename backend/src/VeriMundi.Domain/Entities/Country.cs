namespace VeriMundi.Domain.Entities;

public class Country
{
    public required string Code { get; set; }
    public required string Name { get; set; }
    public required string Region { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
}
