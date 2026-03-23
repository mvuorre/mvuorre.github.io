# Review of “*Analyzing Binary Judgments: A Comparison of ANOVA, Signal Detection Theory, and Generalized Linear Mixed Models in the Context of the Illusory Truth Effect* (Aktepe and Heck, 2026)”

Matti Vuorre
2026-03-23

test In “Analyzing Binary Judgments: A Comparison of ANOVA, Signal Detection Theory, and Generalized Linear Mixed Models in the Context of the Illusory Truth Effect” Aktepe and Heck ([2026](#ref-aktepeAnalyzingBinaryJudgments2026)) examine the performance of three common analytic approaches to binary responses, and find that one method, the general linear mixed model performs better than analyses of aggregated data.

The analyses presented in the manuscript are methodical and thorough, and the finding is well in line with previous literature that finds analysing raw data more informative than their aggregates.

My two suggestions for improving this manuscript both pertain to how it is framed. First, the authors specifically focus on the “illusory truth effect” which, while not particularly niche, is less general than the results presented in this manuscript. That is, the fact that binary responses (whether something is perceived as true or not) provided in illusory truth research are very common, and there is no reason to cordon the present findings into that corner of psychological research. The authors should consider demoting the “illusory truth framing” from the manuscript’s title to an illustrative example, because its implications run far wider as is recognized in the abstract (“GLMMs are \[…\] superior for analyzing binary judgments in social and cognitive psychology.”). Authors may, of course, feel that the current framing is sufficient, in which case they should at least be aware that the impact of their manuscript may be less than it could be.

Second, the manuscript is framed as pitting three methods, ANOVA, Signal Detection Theory, and the General Linear Mixed Model against each other. It would be more accurate, and pedagogically useful, to frame the manuscript to compare two methods: Models of raw data, and models of parameters. Authors could even come up with easy-to-remember heuristic names for these broad approaches: One-step and two-step procedures, for example. For one, the current framing might be understood as falsely suggesting SDT to necessarily be a two-step analytic procedure, but previous work shows that it can and should be conducted on raw data ([Rouder et al. 2007](#ref-rouderSignalDetectionModels2007); [Rouder and Lu 2005](#ref-rouderIntroductionBayesianHierarchical2005)), and therefore the framing suggested here should be more accurate with respect the choices that analysts make in practice.

While the manuscript in its present form is perfectly acceptable, I recommend the authors to carefully consider these suggested improvements to the framing of their analyses.

## Reproduction check

I downloaded the associated OSF repository to do a quick reproducibility check, but could not find any read me file or similar to instruct how to do that. I did manage to run the interpretation.Rmd successfully, but don’t know what or where to look at to confirm results. I suggest authors add a README.md file (or similar) to instruct others how to obtain the results presented in the paper.

## References

<div id="refs" class="references csl-bib-body hanging-indent" entry-spacing="0">

<div id="ref-aktepeAnalyzingBinaryJudgments2026" class="csl-entry">

Aktepe, Semih C, and Daniel W Heck. 2026. “Analyzing Binary Judgments: A Comparison of ANOVA, Signal Detection Theory, and Generalized Linear Mixed Models in the Context of the Illusory Truth Effect.” PsyArXiv. <https://osf.io/preprints/psyarxiv/xn397_v1/>.

</div>

<div id="ref-rouderIntroductionBayesianHierarchical2005" class="csl-entry">

Rouder, Jeffrey N., and Jun Lu. 2005. “An Introduction to Bayesian Hierarchical Models with an Application in the Theory of Signal Detection.” *Psychonomic Bulletin & Review* 12 (4): 573–604. <https://doi.org/10.3758/BF03196750>.

</div>

<div id="ref-rouderSignalDetectionModels2007" class="csl-entry">

Rouder, Jeffrey N., Jun Lu, Dongchu Sun, Paul Speckman, Richard D. Morey, and Moshe Naveh-Benjamin. 2007. “Signal Detection Models with Random Participant and Item Effects.” *Psychometrika* 72 (4): 621–42. <https://doi.org/10.1007/s11336-005-1350-6>.

</div>

</div>

## Declarations

This review of Aktepe and Heck ([2026](#ref-aktepeAnalyzingBinaryJudgments2026)) is contributed by Matti Vuorre under CC-BY to Behavior Research Methods and the [PREreview](https://prereview.org/profiles/0000-0001-5052-066X) platform.
