library(stringi)
library(rollama)
library(magrittr)
library(markdown)
#set working directory to the directory of the file
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

model <- "smollm:360m"
options(rollama_model = model)

# List A – Core Concepts, Frameworks, and Names
list_A <- c(
  "Arrow", "Debreu", "Walrasian", "Edgeworth", "Pareto", "Lindahl", "Coase",
  "Pigouvian", "Samuelson", "Slutsky", "Roy", "Shephard", "Hotelling", "Hicks",
  "Marshall", "Nash", "Kalai-Smorodinsky", "Rubinstein", "Spence",
  "Rothschild-Stiglitz", "Myerson", "Vickrey", "Gibbard", "Satterthwaite",
  "Becker", "Akerlof", "Heckman", "Lucas", "Barro-Gordon", "Ricardian",
  "Schumpeterian", "Friedman", "Keynesian", "New Keynesian",
  "Real Business Cycle", "DSGE", "OLG (Overlapping Generations)", "Ramsey",
  "Tullock", "Tatonnement", "Afriat", "Topkis", "Gross Substitutes",
  "Dynamic Programming", "Bellman", "Mechanism Design", "Auction Theory",
  "Matching Theory", "Revealed Preference", "Von Neumann", "Morgenstern",
  "Cournot", "Bertrand", "Stackelberg", "Shapley", "Gale", "Arrow-Pratt",
  "Laffer", "Okun", "Solow", "Romer", "Harrod-Domar", "Kaldor",
  "Tinbergen", "Muth", "Hayek", "Leontief", "Keynes", "Tobin",
  "Fama", "Mundell", "Fleming", "Blanchard", "Krugman", "Stiglitz"
)

# List B – Analytical Lenses / Objects of Study
list_B <- c(
  "Equilibrium", "Disequilibrium", "Stability", "Pricing", "Taxation", "Subsidies",
  "Efficiency", "Welfare Theorem", "Demand", "Supply", "Production Function",
  "Cost Function", "Expenditure Function", "Utility Function", "Indirect Utility",
  "Savings", "Consumption", "Risk Aversion", "Certainty Equivalent", "Bargaining",
  "Contract Design", "Competition", "Collusion", "Signaling", "Screening",
  "Insurance", "Public Goods", "Club Goods", "Externalities",
  "Information Asymmetry", "Incentive Compatibility", "Game Theory",
  "Evolutionary Dynamics", "Dynamic Games", "Comparative Statics",
  "Supermodularity", "Growth Model", "Business Cycle", "Phillips Curve",
  "Search and Matching", "Human Capital", "Discrimination", "Estimation",
  "Identification", "Auctions", "Labor Markets", "Marriage Markets",
  "Structural Models", "Dynamic Optimization", "Duality", "Elasticity",
  "Isoquants", "Isocosts", "Profit Maximization", "Cost Minimization",
  "Utility Maximization", "Expenditure Minimization", "Production Efficiency",
  "Allocative Efficiency", "Market Failure", "Pareto Efficiency",
  "Social Welfare", "Regulation", "Price Controls", "Monetary Policy",
  "Fiscal Policy", "Trade Models", "Exchange Rates", "Capital Accumulation",
  "Wealth Distribution", "Innovation", "Technological Change"
)

# List C – Contexts, Conditions, and Extensions
list_C <- c(
  "under Uncertainty", "in Dynamic Settings", "in Stochastic Environments",
  "in Incomplete Markets", "with Sticky Prices", "with Menu Costs",
  "in Overlapping Generations", "in Continuous Time", "in Discrete Choice Models",
  "with Rational Expectations", "with Behavioral Biases", "with Risk Neutrality",
  "with Risk Aversion", "in Principal-Agent Models", "in Multi-Agent Systems",
  "in General Equilibrium", "in Partial Equilibrium", "in Competitive Markets",
  "in Monopolistic Markets", "in Oligopolistic Markets", "in Repeated Games",
  "in Infinitely Repeated Games", "with Asymmetric Information",
  "with Perfect Information", "with Imperfect Monitoring",
  "with Heterogeneous Agents", "with Endogenous Growth", "with Exogenous Shocks",
  "in Auction Environments", "under Time Inconsistency",
  "in Rational Expectations Models", "with Quasi-Linear Preferences",
  "with Cobb-Douglas Preferences", "with CES Preferences", "in Matching Markets",
  "with Incomplete Contracts", "with Contract Enforcement Frictions",
  "in Monetary Economies", "in Fiscal Policy Contexts", "in Structural Estimation",
  "in Dynamic Optimization", "with Habit Formation", "in Life-Cycle Models",
  "in Search-Theoretic Models", "in DSGE Frameworks", "in International Trade",
  "in Open Economies", "with Financial Frictions", "under Monetary Union",
  "with Technology Shocks", "in Capital Markets", "in Credit Markets",
  "with Liquidity Constraints", "with Demographic Change",
  "in Housing Markets", "in Labor Market Search", "with Policy Uncertainty",
  "under Globalization", "with Environmental Constraints",
  "in Resource Economics", "with Inequality", "with Market Power",
  "in Network Models", "with Digital Platforms", "in Algorithmic Markets"
)

# find the product 
total_articles_possible <- length(unique(list_A)) * length(unique(list_B)) * length(unique(list_C))
cat("Total number of articles: ", total_articles_possible, "\n")

# Function to generate a single random topic
generate_topic <- function() {
  paste(
    sample(list_A, 1, replace = TRUE),
    sample(list_B, 1, replace = TRUE),
    sample(list_C, 1, replace = TRUE)
  )
}

get_response <- function(prompt) {
  rollama::query(prompt, output = "text",screen=FALSE,
      model_params = list(
        temperature = 0.1
      )
      )  
}


make_prompt_from_topic <- function(topic) {
  paste0("Write an article about the following topic: ", topic)
}

make_markdown_article_from_topic_and_content <- function(topic, content) {
  paste0("# ", topic, "\n\n", content)
}

make_filename_from_topic <- function(topic, extension) {
  paste0(gsub(" ", "_", topic), ".", extension)
}

# Create output directories
dir.create("markdown_articles", showWarnings = FALSE)

# Configuration for periodic operations
GENERATIONS_BETWEEN_HTML_UPDATE <- 10  # Change this to adjust frequency
html_update_counter <- 0

# Continuous article generation loop
article_count <- 0
cat("Starting continuous article generation...\n")
cat("HTML will be regenerated and pushed to GitHub every", GENERATIONS_BETWEEN_HTML_UPDATE, "generations\n")
cat("Press Ctrl+C to stop\n\n")
# while article_count is less than total_articles_possible
while (article_count < total_articles_possible) {
    articles <- list.files("markdown_articles", full.names = TRUE)
    articles_count <- length(articles)
    #check if article already exists
    article_exists <- TRUE
    while (article_exists) {
      topic <- generate_topic()
      markdown_filename <- make_filename_from_topic(topic, "md")
      if (!any(grepl(markdown_filename, articles))) {
        article_exists <- FALSE
      }
      Sys.sleep(0.1)
    }
    cat("Generating article", articles_count + 1, ":", topic, "\n")
    prompt <- make_prompt_from_topic(topic)
    content <- get_response(prompt)
    markdown_article <- make_markdown_article_from_topic_and_content(topic, content)
    markdown_filename <- make_filename_from_topic(topic, "md")
    cat("Writing to file: ", markdown_filename, "\n")
    writeLines(markdown_article, file.path("markdown_articles", markdown_filename))
    cat("Article", articles_count + 1, "saved successfully!\n\n")
    
    # Increment counter and check if it's time for HTML update
    html_update_counter <- html_update_counter + 1
    if (html_update_counter >= GENERATIONS_BETWEEN_HTML_UPDATE) {
      cat("Time for an HTML update and GitHub push.")
        source("html_maker.r")
        cat("Pushing to GitHub")
        system("git_push.bat", wait = TRUE)
        html_update_counter <- 0  # Reset counter
    }
  }



