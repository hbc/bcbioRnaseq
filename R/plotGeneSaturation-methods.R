#' Plot Gene Detection Saturation
#'
#' @name plotGeneSaturation
#' @family Quality Control Functions
#' @author Michael Steinbaugh, Rory Kirchner, Victor Barrera
#'
#' @inheritParams general
#' @param trendline Include a trendline for each group.
#'
#' @return `ggplot`.
#'
#' @examples
#' plotGeneSaturation(bcb_small, label = FALSE)
#' plotGeneSaturation(bcb_small, label = TRUE)
NULL



# Methods ======================================================================
#' @rdname plotGeneSaturation
#' @export
setMethod(
    "plotGeneSaturation",
    signature("bcbioRNASeq"),
    function(
        object,
        normalized = c("tpm", "tmm"),
        interestingGroups,
        minCounts = 1L,
        label = FALSE,
        trendline = FALSE,
        color = NULL,
        title = "gene saturation"
    ) {
        validObject(object)
        normalized <- match.arg(normalized)
        if (missing(interestingGroups)) {
            interestingGroups <- basejump::interestingGroups(object)
        } else {
            interestingGroups(object) <- interestingGroups
        }
        assertIsAnImplicitInteger(minCounts)
        assert_all_are_in_range(minCounts, lower = 1L, upper = Inf)
        assert_is_a_bool(trendline)
        assertIsColorScaleDiscreteOrNULL(color)
        assertIsAStringOrNULL(title)

        counts <- counts(object, normalized = normalized)
        p <- metrics(object) %>%
            mutate(geneCount = colSums(!!counts >= !!minCounts)) %>%
            ggplot(
                mapping = aes(
                    x = !!sym("mappedReads") / 1e6L,
                    y = !!sym("geneCount"),
                    color = !!sym("interestingGroups")
                )
            ) +
            geom_point(size = 3L) +
            labs(
                title = title,
                x = "mapped reads per million",
                y = "gene count",
                color = paste(interestingGroups, collapse = ":\n")
            )

        if (isTRUE(trendline)) {
            p <- p + geom_smooth(method = "lm", se = FALSE)
        }

        if (is(color, "ScaleDiscrete")) {
            p <- p + color
        }

        if (isTRUE(label)) {
            p <- p + bcbio_geom_label_repel(
                mapping = aes(label = !!sym("sampleName"))
            )
        }

        p
    }
)