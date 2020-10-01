import pandas as pd
import seaborn as sns
import math

test = pd.read_excel('C:/Users/paulo/Documents/Homicide Rate and Incarceration Rate.xls', sheet_name = 'Total Data')


sns.scatterplot('hom_rate','inc_rate',hue='us_flag',data = test)
sns.scatterplot('inc_rate','hom_rate',hue='us_flag',data = test[test['IncomeGroup']=='High income'])
sns.scatterplot('inc_rate','log_hom_rate',hue='us_flag',data = test[test['IncomeGroup']=='High income'])
sns.scatterplot('log_inc_rate','log_hom_rate',data = test[test['IncomeGroup']=='High income'])
sns.scatterplot('log_hom_rate','log_inc_rate',hue='us_flag',data = test[test['IncomeGroup']=='High income'])

sns.scatterplot('log_inc_rate','log_hom_rate',hue='us_flag',data = test)

sns.lmplot('hom_rate','inc_rate',hue='us_flag',data = test)
sns.lmplot('hom_rate','inc_rate',hue='us_flag',data = test[test['IncomeGroup']=='High income'])

sns.lmplot('log_hom_rate','log_inc_rate',hue='us_flag',data = test)
sns.lmplot('log_hom_rate','log_inc_rate',hue='us_flag',data = test[test['IncomeGroup']=='High income'])

