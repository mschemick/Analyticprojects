
# coding: utf-8

# # Import packages and load CSV

# In[1]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns


# In[2]:


df = pd.read_csv('C:/Users/crazy/Documents/crash_data3.csv')


# # Dataframe Description

# In[18]:


df.head()


# In[19]:


df.tail()


# In[20]:


df.shape


# In[21]:


print(df.info())


# # Working on Missing data

# In[22]:


df.isna().sum()


# ### missing lon and lat data

# In[23]:


df.lon = df.lon.fillna(value=df.lon2)
df.lat = df.lat.fillna(value=df.lat2)


# ### Dropping missing values

# In[24]:


df = df[df['location_description'].notna()]


# In[25]:


df = df.dropna(subset=['rdfeature', 'rdclass'], thresh=2)


# ### cleaning of missing values

# In[26]:


## Checking to see if rdclass could be a reason for missing data in rdconfigur column. (ex = parking lot)

rdconfignan = df[df['rdconfigur'].isnull()]
rdconfignan['rdclass'].value_counts()


# In[27]:


df['rdconfigur']=df.groupby('rdclass')['rdconfigur'].apply(lambda x: x.fillna(x.mode().iat[0]))


# In[28]:


### rdcharacter is either straight or curve

df['rdcharacter']=df['rdcharacter'].fillna(method='ffill')


# In[29]:


df['rdsurface'].value_counts()


# In[30]:


df['rdsurface']=df.groupby('rdclass')['rdsurface'].apply(lambda x: x.fillna(x.mode().iat[0]))


# In[31]:


colnames = ['rdcondition', 'sun_pos', 'weather_day', 'workarea']
df[colnames] = df[colnames].apply(lambda x: x.fillna(x.mode))
df['trafcontrl']=df['trafcontrl'].fillna('unknown')


# In[32]:


### value was only inputed if one or more were present

df['numpedestrians']=df['numpedestrians'].fillna(0)
df['numpassengers']=df['numpassengers'].fillna(0)


# In[33]:


colnames2 = ['contrcir1_desc', 'contrcir2_desc', 'contrcir3_desc', 'contrcir4_desc']
df[colnames2]=df[colnames2].fillna('NONE')


# ### Deleting columns that won't be used for analysis

# In[34]:


del df['tract']
del df['zone']
del df['contrfact1']
del df['contrfact2']
del df['contributing_factor']
del df['vehicleconcat1']
del df['vehicleconcat2']
del df['vehicleconcat3']


# In[35]:


df.isna().sum()


# ## Create new dataframes for vehicles and contributing factors

# In[36]:


vehicles = df[['tamainid', 'vehicle1', 'vehicle2', 'vehicle3', 'vehicle4', 'vehicle5']].copy()
factors = df[['tamainid', 'contrcir1_desc', 'contrcir2_desc', 'contrcir3_desc', 'contrcir4_desc']].copy()


# In[37]:


vehicles.head()


# In[38]:


factors.head()


# In[39]:


vehicles = pd.melt(vehicles, id_vars=['tamainid'], var_name='vehicle1_5', value_name='vehicle')
print(vehicles)


# In[40]:


factors = pd.melt(factors, id_vars=['tamainid'], var_name='contrib', value_name='factor')
print(factors)


# In[41]:


del vehicles['vehicle1_5']
del factors['contrib']


# In[42]:


vehicles = vehicles[vehicles['vehicle'].notna()]


# In[43]:


print(vehicles)


# ## Exploratory Analysis

# #### Questions to ask
# 
# 1. What roads do accidents occur most on?  (road feature, surface, class)
# 2. When do most accidents occur during the day?  What Month do most accidents occur on?
# 3. What type of vehicles are involved in most accidents?
# 4. Does weather have an impact on the number of accidents?
# 5. What types of contributing factors impact the number of accidents?
# 
# #### Exploratory answers and notes
# 
# 1. Intersections especially four way intersections, straight level roads, secondary state roads and public vehicular areas, two-way not divided, and smooth asphalt

# #### Exploring the first question

# In[44]:


## Exploring rdfeature

plt.figure(figsize=(12,8))
ax = sns.countplot(x='rdfeature', data=df[-(df.rdfeature == 'NO SPECIAL FEATURE')])
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# #### Sub Question = Does traffic control impact accidents on intersections

# In[45]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='trafcontrl', data=df)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# In[46]:


## Exploring rdfeature

plt.figure(figsize=(12,8))
ax = sns.countplot(x='rdcharacter', data=df)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# In[47]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='rdclass', data=df)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# In[48]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='rdconfigur', data=df)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# In[49]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='rdsurface', data=df)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# #### Exploring the second question

# In[50]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='Day_Of_Week', data=df, order=df['Day_Of_Week'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# In[51]:


df['month'].replace([1,2,3,4,5,6,7,8,9,10,11,12],['January','February','March','April','May','June','July','August','September','October','November','December'],inplace=True)


# In[52]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='month', data=df, order=df['month'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# In[53]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='Time_Rounded', data=df, order=df['Time_Rounded'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# #### Sub Question, can light condition have a difference on the number of accidents

# In[14]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='sun_pos', data=df, order=df['sun_pos'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# #### Question 3

# In[54]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='vehicle', data=vehicles, order=vehicles['vehicle'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# #### Question 4

# In[15]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='weather_day', data=df, order=df['weather_day'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha='right')
plt.tight_layout()
plt.show()


# In[17]:


## Removing Clear from the graph

plt.figure(figsize=(12,8))
ax = sns.countplot(x='weather_day', data=df[-(df.weather_day == 'CLEAR')], order=df['weather_day'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# #### Question 5

# In[55]:


plt.figure(figsize=(12,8))
ax = sns.countplot(x='factor', data=factors, order=factors['factor'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()


# In[56]:


## Removing Value None from the graph

plt.figure(figsize=(12,8))
ax = sns.countplot(x='factor', data=factors[-(factors.factor == 'NONE')], order=factors['factor'].value_counts().index)
ax.set_xticklabels(ax.get_xticklabels(), rotation=40, ha="right")
plt.tight_layout()
plt.show()

