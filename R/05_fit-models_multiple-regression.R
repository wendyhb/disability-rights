source("R/my-packages.R")

dat_2022 <- read_rds("output/dat_2022.rds")
data_2022 <-dat_2022 |> 
  ungroup() |> 
  select(-c(crpd_cat, year, democracy_cat, gdp_cat, country))


# filtered_data <- na.omit(data_2022)
# filtered_data |> nrow()

# this model does not work for linear regression
# dependent variable can not be categorical
# model <- lm(crpd ~ corruption_score + 
                    # democracy +  
                    # freedom_index +
                    # gdp_per_capita + 
                    # human_development_index +
                    # life_expectancy +
                    # expected_years_of_schooling + 
                    # mean_years_of_schooling + 
                    # crime_index +
                    # safety_index +
                    # unemployment_rate +
                    # power_distance +
                    # individualism + 
                    # motivation+
                    # uncertainty_avoidance + 
                    # long_term_orientation + 
                    # indulgence + 
                    # masculinity, data = data_2022)


# Other -------------------------------------------------------------------
library(sjmisc)

cols_many_missing <- data_2022 %>%
  mutate(id = row_number()) %>%
  gather(-id, key = "key", value = "val") %>%
  mutate(isna = is.na(val)) |> 
  summarize(.by = key, missing = sum(isna)) |> 
  arrange(missing) |> 
  filter(missing > 50) |> 
  pull(key)


# -------------------------------------------------------------------------

dat <- data_2022 |> dplyr::select(everything(), - all_of(cols_many_missing))

dat <- dat[complete.cases(dat), ]

dat <- dat |> 
  filter(crpd > 1) |> 
  mutate(crpd = case_match(
    crpd, 
    4 ~ 1,
    3 ~ 0
    ) |> as_factor())

clean_data <- na.omit(dat)
## Forward Stepwise Selection
intercept_only <- glm(crpd ~ 1, data = clean_data, family = "binomial")
#define model with all predictors
all <- glm(crpd ~ ., data = clean_data, family = "binomial")
#perform forward stepwise regression
forward <- step(intercept_only, direction='forward', scope=formula(all), trace=0)

plot(forward)
library(InformationValue)
optimal <- optimalCutoff(forward$data$crpd, forward$fitted.values)[1]

confusionMatrix(forward$data$crpd, forward$fitted.values)

#calculate sensitivity
sensitivity(forward$data$crpd, forward$fitted.values)

#calculate specificity
specificity(forward$data$crpd, forward$fitted.values)

#calculate total misclassification error rate
misClassError(forward$data$crpd, forward$fitted.values)


plotROC(forward$data$crpd, forward$fitted.values)

forward |> broom::tidy()

forward |>
  broom::tidy() |> 
  transmute(logodds = exp(estimate))


# Missing plot ------------------------------------------------------------

row.plot <- data_2022 %>%
  mutate(id = row_number()) %>%
  gather(-id, key = "key", value = "val") %>%
  mutate(isna = is.na(val)) %>%
  ggplot(aes(key, id, fill = isna)) +
  geom_raster(alpha=0.8) +
  scale_fill_manual(name = "",
                    values = c('steelblue', 'tomato3'),
                    labels = c("Present", "Missing")) +
  labs(x = "Variable",
       y = "Row Number", title = "Missing values in rows") +
  coord_flip()

row.plot



