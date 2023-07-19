import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

export const HealthTopics = () => {
  return (
    <div className='search-item-wrapper'>
      <GridContainer className="health-topic-wrapper">
        <Grid row gap="md">
          <Grid col={true}>
            <GridContainer className='health-topic-title'>
              Pneumonia<img src="https://d15vqlr7iz6e8x.cloudfront.net/assets/legacy/medline.en-c7be74e1f9f3a1c844732be2aeaf05b5ca9e9f8e706fbc1d0658535330d39ca9.png"></img>
            </GridContainer>
            <GridContainer className='health-topic-data'>
              <Grid row gap="md">
                <Grid col={true} className='health-topic-meta-data'>
                  <div className='health-topic-desc'>
                    <p>What is pneumonia? Pneumonia is an infection in one or both of the lungs. It causes the air sacs of the lungs to fill up with fluid or pus.</p>
                    <div className='related-topics'>Related topics: &nbsp;
                      <a className="usa-link" href="javascript:void(0);">COVID-19 (Coronavirus Disease 2019)</a>, &nbsp; 
                      <a className="usa-link" href="javascript:void(0);">Haemophilus Infections</a>, &nbsp; 
                      <a className="usa-link" href="javascript:void(0);">Legionnaires' Disease</a>
                    </div>
                    <div className='clinical-studies'>Open clinical studies and trials: &nbsp;
                      <a className="usa-link" href="javascript:void(0);">Pneumonia</a>
                    </div>
                  </div>
                </Grid>
              </Grid>
            </GridContainer>
          </Grid>
        </Grid>
      </GridContainer>

      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>Jul 4th, 2022</span>
            
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Pneumonia - What is Pneumonia? | NHLBI, NIH
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>Pneumonia is an infection that affects one or both lungs. It causes the air sacs, or alveoli, of the lungs to fill up with fluid or pus. Bacteria ...</p>
              <div className='result-url-text'>www.nhlbi.nih.gov/health/pneumonia</div>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>
      
      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>May 27th, 2022</span>
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Pneumonia - Causes and Risk Factors | NHLBI, NIH
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>The flu (influenza virus) and the common cold (rhinovirus) are the most common causes of viral pneumonia in adults. Respiratory syncytial virus (RSV) ....</p>
              <div className='result-url-text'>www.nhlbi.nih.gov/health/pneumonia/causes</div>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>

      <GridContainer className='result-divider'>
        <Grid row gap="md">
        </Grid>
      </GridContainer>
    </div>
  );
};
