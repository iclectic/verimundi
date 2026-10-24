using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace VeriMundi.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Countries",
                columns: table => new
                {
                    Code = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: false),
                    Name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    Region = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Latitude = table.Column<double>(type: "double precision", nullable: false),
                    Longitude = table.Column<double>(type: "double precision", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Countries", x => x.Code);
                });

            migrationBuilder.CreateTable(
                name: "Sources",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    CanonicalDomain = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    CountryCode = table.Column<string>(type: "text", nullable: true),
                    PrimaryLanguage = table.Column<string>(type: "text", nullable: false),
                    SourceType = table.Column<int>(type: "integer", nullable: false),
                    WebsiteUrl = table.Column<string>(type: "text", nullable: true),
                    FeedUrl = table.Column<string>(type: "text", nullable: true),
                    Region = table.Column<string>(type: "text", nullable: true),
                    OwnershipMetadata = table.Column<string>(type: "text", nullable: true),
                    LicenceStatus = table.Column<int>(type: "integer", nullable: false),
                    AttributionRequirements = table.Column<string>(type: "text", nullable: true),
                    ContentUsageStatus = table.Column<int>(type: "integer", nullable: false),
                    Enabled = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sources", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Stories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CanonicalHeadline = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    ShortSummary = table.Column<string>(type: "text", nullable: false),
                    FullSummary = table.Column<string>(type: "text", nullable: false),
                    WhyItMatters = table.Column<string>(type: "text", nullable: false),
                    PrimaryCountryCode = table.Column<string>(type: "text", nullable: false),
                    AffectedCountryCodes = table.Column<List<string>>(type: "text[]", nullable: false),
                    Region = table.Column<string>(type: "text", nullable: false),
                    Category = table.Column<int>(type: "integer", nullable: false),
                    Severity = table.Column<int>(type: "integer", nullable: false),
                    SeverityReason = table.Column<string>(type: "text", nullable: false),
                    SeverityConfidence = table.Column<double>(type: "double precision", nullable: false),
                    SeverityUpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    Tone = table.Column<int>(type: "integer", nullable: false),
                    VerificationStatus = table.Column<int>(type: "integer", nullable: false),
                    ConfidenceScore = table.Column<double>(type: "double precision", nullable: false),
                    LocalSourceCount = table.Column<int>(type: "integer", nullable: false),
                    RegionalSourceCount = table.Column<int>(type: "integer", nullable: false),
                    InternationalSourceCount = table.Column<int>(type: "integer", nullable: false),
                    IndependentSourceCount = table.Column<int>(type: "integer", nullable: false),
                    UnderreportedScore = table.Column<double>(type: "double precision", nullable: false),
                    UnderreportedReason = table.Column<string>(type: "text", nullable: false),
                    PositiveImpactScore = table.Column<double>(type: "double precision", nullable: false),
                    RankingReason = table.Column<string>(type: "text", nullable: false),
                    Latitude = table.Column<double>(type: "double precision", nullable: true),
                    Longitude = table.Column<double>(type: "double precision", nullable: true),
                    FirstPublishedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    LastUpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    GeneratedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    HumanReviewStatus = table.Column<int>(type: "integer", nullable: false),
                    InsufficientEvidence = table.Column<bool>(type: "boolean", nullable: false),
                    CorrectedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    CorrectionNotice = table.Column<string>(type: "text", nullable: true),
                    Uncertainties = table.Column<List<string>>(type: "text[]", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Articles",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SourceId = table.Column<Guid>(type: "uuid", nullable: false),
                    CanonicalUrl = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    Headline = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    PermittedExcerpt = table.Column<string>(type: "text", nullable: true),
                    Author = table.Column<string>(type: "text", nullable: true),
                    PublishedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    Language = table.Column<string>(type: "text", nullable: false),
                    SourceCountryCode = table.Column<string>(type: "text", nullable: true),
                    DiscoveredAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ImageUrl = table.Column<string>(type: "text", nullable: true),
                    IngestionProvider = table.Column<string>(type: "text", nullable: false),
                    ContentHash = table.Column<string>(type: "text", nullable: false),
                    CanonicalHash = table.Column<string>(type: "text", nullable: false),
                    ProcessingStatus = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Articles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Articles_Sources_SourceId",
                        column: x => x.SourceId,
                        principalTable: "Sources",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Claims",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    StoryId = table.Column<Guid>(type: "uuid", nullable: false),
                    Text = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    Confidence = table.Column<double>(type: "double precision", nullable: false),
                    FirstObservedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    LastObservedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Claims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Claims_Stories_StoryId",
                        column: x => x.StoryId,
                        principalTable: "Stories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "StoryArticleLinks",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    StoryId = table.Column<Guid>(type: "uuid", nullable: false),
                    ArticleId = table.Column<Guid>(type: "uuid", nullable: false),
                    Relationship = table.Column<string>(type: "text", nullable: false),
                    SimilarityScore = table.Column<double>(type: "double precision", nullable: false),
                    SourceCoverageClass = table.Column<int>(type: "integer", nullable: false),
                    AddedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StoryArticleLinks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StoryArticleLinks_Articles_ArticleId",
                        column: x => x.ArticleId,
                        principalTable: "Articles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StoryArticleLinks_Stories_StoryId",
                        column: x => x.StoryId,
                        principalTable: "Stories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ClaimEvidence",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ClaimId = table.Column<Guid>(type: "uuid", nullable: false),
                    ArticleId = table.Column<Guid>(type: "uuid", nullable: false),
                    Relationship = table.Column<string>(type: "text", nullable: false),
                    Supports = table.Column<bool>(type: "boolean", nullable: false),
                    Disputes = table.Column<bool>(type: "boolean", nullable: false),
                    ContextOnly = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClaimEvidence", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ClaimEvidence_Articles_ArticleId",
                        column: x => x.ArticleId,
                        principalTable: "Articles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ClaimEvidence_Claims_ClaimId",
                        column: x => x.ClaimId,
                        principalTable: "Claims",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Articles_CanonicalHash",
                table: "Articles",
                column: "CanonicalHash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Articles_ContentHash",
                table: "Articles",
                column: "ContentHash");

            migrationBuilder.CreateIndex(
                name: "IX_Articles_SourceId",
                table: "Articles",
                column: "SourceId");

            migrationBuilder.CreateIndex(
                name: "IX_ClaimEvidence_ArticleId",
                table: "ClaimEvidence",
                column: "ArticleId");

            migrationBuilder.CreateIndex(
                name: "IX_ClaimEvidence_ClaimId",
                table: "ClaimEvidence",
                column: "ClaimId");

            migrationBuilder.CreateIndex(
                name: "IX_Claims_StoryId",
                table: "Claims",
                column: "StoryId");

            migrationBuilder.CreateIndex(
                name: "IX_Sources_CanonicalDomain",
                table: "Sources",
                column: "CanonicalDomain",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Stories_PositiveImpactScore",
                table: "Stories",
                column: "PositiveImpactScore");

            migrationBuilder.CreateIndex(
                name: "IX_Stories_PrimaryCountryCode",
                table: "Stories",
                column: "PrimaryCountryCode");

            migrationBuilder.CreateIndex(
                name: "IX_Stories_UnderreportedScore",
                table: "Stories",
                column: "UnderreportedScore");

            migrationBuilder.CreateIndex(
                name: "IX_StoryArticleLinks_ArticleId",
                table: "StoryArticleLinks",
                column: "ArticleId");

            migrationBuilder.CreateIndex(
                name: "IX_StoryArticleLinks_StoryId_ArticleId",
                table: "StoryArticleLinks",
                columns: new[] { "StoryId", "ArticleId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ClaimEvidence");

            migrationBuilder.DropTable(
                name: "Countries");

            migrationBuilder.DropTable(
                name: "StoryArticleLinks");

            migrationBuilder.DropTable(
                name: "Claims");

            migrationBuilder.DropTable(
                name: "Articles");

            migrationBuilder.DropTable(
                name: "Stories");

            migrationBuilder.DropTable(
                name: "Sources");
        }
    }
}
