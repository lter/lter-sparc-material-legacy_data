## Download Raw Data

All of the data used in this project has previously been published with the [Environmental Data Initiative](https://edirepository.org/) (EDI). The scripts in this folder download those files directly from EDI so that subsequent scripts can work with those data without requiring users to download those files manually.

### EDI Authentication

Due to a number of DDoS attacks on EDI in 2026, **you'll need to authenticate before being able to download data.** For instructions, see either of this [YouTube Tutorial](https://youtu.be/fieZSmHk2H4?si=Wo9a5GsAOYp3dnWS) or check out EDI's [Identity & Access Manager](https://auth.edirepository.org) (IAM)

Once you have a key, it will be easiest if you make a file that starts with "secret" (e.g., "secret_my-edi-key.md") and copy/paste the key from that file into the "Console" of your IDE when the download code interactively prompts you to do so.

**DO NOT COMMIT THIS FILE!** All files beginning with "secret" have been preemptively added to the `.gitignore` but if you name it something else, you'll be at risk of committing it. 

### Site Abbreviations

Script names end with the three-letter abbreviation of the LTER site to which the data belong. See the LTER's [Site Characteristics table](https://lternet.edu/site-characteristics/) to identify the full name that corresponds with a given abbreviation.
