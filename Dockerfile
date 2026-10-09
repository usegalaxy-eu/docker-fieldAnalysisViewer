# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Stage 1: builder — installs R packages into separate layers
# ---------------------------------------------------------------------------
FROM rocker/shiny-verse:4.4.1 AS builder

# Group 1: dashboard / rendering stack (rarely changes)
RUN Rscript -e 'install.packages(c( \
      "flexdashboard", \
      "rmarkdown" \
    ), repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest", Ncpus = parallel::detectCores())'

# Group 2: data handling (changes rarely)
RUN Rscript -e 'install.packages("data.table", \
    repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest", Ncpus = parallel::detectCores())'

# Group 3: interactive graphics
RUN Rscript -e 'install.packages(c( \
      "plotly", \
      "ggiraph", \
      "kableExtra" \
    ), repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest", Ncpus = parallel::detectCores())'

# Group 4: data tables
RUN Rscript -e 'install.packages("DT", \
    repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest", Ncpus = parallel::detectCores())'

# Group 4: spatial statistics (heavy, changes rarely)
RUN Rscript -e 'install.packages("SpATS", \
    repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest", Ncpus = parallel::detectCores())'

# ---------------------------------------------------------------------------
# Stage 2: runtime — only the compiled package libraries are copied over
# ---------------------------------------------------------------------------
FROM rocker/shiny-verse:4.4.1

COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

COPY --chown=shiny:shiny app /srv/shiny-server/app

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
