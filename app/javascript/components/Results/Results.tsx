import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

import { Pagination } from './../Pagination/Pagination';
import { BestBets } from './BestBets';
import { truncateUrl } from '../../utils';

import './Results.css';
interface ResultsProps {
  query?: string
  results?: {
    title: string,
    url: string,
    thumbnail?: {
      url: string
    },
    description: string,
    updatedDate?: string,
    publishedDate?: string,
    thumbnailUrl?: string
  }[] | null;
  additionalResults?: {
    recommendedBy: string;
    textBestBets?: {
      title: string;
      url: string;
      description: string;
    }[];
    graphicsBestBet?: {
      title: string;
      titleUrl?: string;
      imageUrl?: string;
      imageAltText?: string;
      links?: {
        title: string;
        url: string;
      }[];
    }
  } | null;
  unboundedResults: boolean;
  totalPages: number | null;
  vertical: string;
}

export const Results = ({ query = '', results = null, additionalResults = null, unboundedResults, totalPages = null, vertical }: ResultsProps) => {
  const imagesToBeDynamic = [
    {
      url: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 1'
    },
    {
      url: 'https://images.unsplash.com/flagged/photo-1552483570-019b7f8119b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 2'
    },
    {
      url: 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bmFzYXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 3'
    },
    {
      url: 'https://images.unsplash.com/photo-1502134249126-9f3755a50d78?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bmFzYXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 4'
    },
    {
      url: 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNhbHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 5'
    }
  ];

  const URL_LENGTH = 80;
  return (
    <>
      <div className='search-result-wrapper'>
        {additionalResults && (
          <BestBets
            {...additionalResults}
            parse={parse}
          />
        )}
        <div id="results" className="search-result-item-wrapper">
          
          {/* Health topics:starts to be dynamic - To Do as part of backend integration */}
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
          {/* Health topics:ends to be dynamic - To Do as part of backend integration */}

          
          {/* Image Components:starts to be dynamic - To Do as part of backend integration */}
          <GridContainer className='result search-result-item search-result-image-item'>
            <Grid row gap="md">
              {(imagesToBeDynamic.map((image, index) => {
                return (
                  <Grid key={index} mobileLg={{ col: 4 }} className='result-thumbnail margin-bottom-4'>
                    <img src={image.url} className="result-image" alt={image.title} />
                  </Grid>
                );
              }))}
            </Grid>
          </GridContainer>
          {/* Image Components:ends to be dynamic - To Do as part of backend integration */}
          
          {/* RSS Component:starts - needs to be dynamic - TBD with its integration task */}
          <div className='search-item-wrapper search-news-item-wrapper'>
            <GridContainer className='news-title-wrapper'>
              <Grid row gap="md">
                <h2 className='news-title-wrapper-label'>
                  News about Benefits
                </h2>
              </Grid>
            </GridContainer>
            
            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <span className='published-date'>1 hr</span>
                  
                  <div className='result-title'>
                    <a href="" className='result-title-link'>
                      <h2 className='result-title-label'>
                        Benefit eligibility for married same-sex couples
                      </h2>
                    </a>
                  </div>
                  <div className='result-desc'>
                    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, potential eligibility for benefits by survivors ullamco laboris nisi ut aliquip ex ea commodo consequat...</p>
                    <div className='result-url-text'>https://www.news.com</div>
                  </div>
                </Grid>
              </Grid>
              <Grid row className="row-mobile-divider"></Grid>
            </GridContainer>
            
            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <span className='published-date'>17 hrs ago</span>
                  <div className='result-title'>
                    <a href="" className='result-title-link'>
                      <h2 className='result-title-label'>
                        Benefits Planner: Retirement | Benefits For Your Family | SSA
                      </h2>
                    </a>
                  </div>
                  <div className='result-desc'>
                    <p>Find out your full retirement age, which is when you become eligible for unreduced Social Security retirement benefits. The year and month you reach full retirement age depends on the year you were born.</p>
                    <div className='result-url-text'>https://www.news.com</div>
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
          {/* RSS Component:starts - needs to be dynamic - TBD with its integration task */}

          {/* Video Component:starts - needs to be dynamic - TBD with its integration task */}
          <div className='search-item-wrapper fed-register-item-wrapper'>
            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                  <img src='https://images.unsplash.com/photo-1603398938378-e54eab446dde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNhbHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60' className="result-image" alt="image title"/>
                  <div className="video-duration">
                    <div className="tri-icon"></div>
                    <span>42:02</span>
                  </div>
                </Grid>
                <Grid col={true} className='result-meta-data'>
                  <span className='published-date'>About 1 month ago</span>
                  <div className='result-title'>
                    <a href="" className='result-title-link'>
                      <h2 className='result-title-label'>
                        Violent Tornado Animation of an EF5 Supercell
                      </h2>
                    </a>
                  </div>
                  <div className='result-desc'>
                    <p>Watch search.gov’s training video on how to get the search right on your site.</p>
                    <div className='result-url-text'>https://youtube.com/Ed4%53Wt/searchtraining</div>
                  </div>
                </Grid>
              </Grid>
              <Grid row className="row-mobile-divider"></Grid>
            </GridContainer>
            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                  <img src='https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60' className="result-image" alt="image title"/>
                  <div className="video-duration">
                    <div className="tri-icon"></div>
                    <span>1:22:02</span>
                  </div>
                </Grid>
                <Grid col={true} className='result-meta-data'>
                  <span className='published-date'>about 5 years ago</span>
                  <div className='result-title'>
                    <a href="" className='result-title-link'>
                      <h2 className='result-title-label'>
                        Enhanced Fujita Scale for Tornadoes
                      </h2>
                    </a>
                  </div>
                  <div className='result-desc'>
                    <p>Incredible For tornado safety tips and information, visit: weather.gov/tornado</p>
                    <div className='result-url-text'>https://www.youtube.com/watch?v=Bl41fLm2KGs</div>
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
          {/* Video Component:ends - needs to be dynamic - TBD with its integration task */}

          {/* Federal register:starts - needs to be dynamic - TBD with its integration task */}
          <div className='search-item-wrapper fed-register-item-wrapper'>
            <GridContainer className='fed-register-wrapper'>
              <Grid row gap="md">
                <h2 className='fed-register-label'>
                  Federal Register documents about Benefits
                </h2>
              </Grid>
            </GridContainer>
            
            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <span className='published-date'>May 11, 2011</span>
                  
                  <div className='result-title'>
                    <a href="" className='result-title-link'>
                      <h2 className='result-title-label'>
                        Unsuccessful Work Attempts and Expedited Reinstatement
                      </h2>
                    </a>
                  </div>
                  <div className='result-desc'>
                    <p>A Proposed Rule by the Social Security Administration</p>
                    <div className='pages-count'>Pages 29212 - 29215 (4 pages) [FR DOC #: 2016-10932]</div>
                    <div className='comment-period'>Comment period ends July 6, 2023</div>
                  </div>
                </Grid>
              </Grid>
              <Grid row className="row-mobile-divider"></Grid>
            </GridContainer>

            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <span className='published-date'>May 11, 2016</span>
                  
                  <div className='result-title'>
                    <a href="" className='result-title-link'>
                      <h2 className='result-title-label'>
                        Unsuccessful Work Attempts and Expedited Reinstatement Eligibility
                      </h2>
                    </a>
                  </div>
                  <div className='result-desc'>
                    <p>A Proposed Rule by the Social Security Administration</p>
                    <div className='pages-count'>Pages 29212 - 29215 (4 pages) [FR DOC #: 2016-10932]</div>
                    <div className='comment-period-ended'>Comment period has ended</div>
                  </div>
                </Grid>
              </Grid>
              <Grid row className="row-mobile-divider"></Grid>
            </GridContainer>

            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <span className='published-date'>July 29, 2013.</span>
                  
                  <div className='result-title'>
                    <a href="" className='result-title-link'>
                      <h2 className='result-title-label'>
                        Mailing of Tickets Under the Ticket To Work Program
                      </h2>
                    </a>
                  </div>
                  <div className='result-desc'>
                    <p>A Rule by the Department of Veterans Affairs, the Office of Personnel Management, the Railroad Retirement Board, the Social Security Administration and the Treasury Department</p>
                    <div className='pages-count'>Pages 29212 - 29215 (4 pages) [FR DOC #: 2016-10932]</div>
                    <div className='comment-period-ended'>Comment period has ended</div>
                  </div>
                </Grid>
              </Grid>
              <Grid row className="row-mobile-divider"></Grid>
            </GridContainer>

            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <div className='result-title'>
                    <a href="" className='more-fed-register-link'>
                      More SSA documents on FederalRegister.gov
                    </a>
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
          {/* Federal register:ends - needs to be dynamic - TBD with its integration task */}

          {results && results.length > 0 ? (results.map((result, index) => {
            return (
              <GridContainer key={index} className='result search-result-item'>
                <Grid row gap="md">
                  {vertical === 'image' &&
                  <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                    <img src={result.thumbnail?.url} className="result-image" alt={result.title}/>
                  </Grid>
                  }
                  <Grid col={true} className='result-meta-data'>
                    {result.publishedDate && (<span className='published-date'>{result.publishedDate}</span>)}
                    {result.updatedDate && (<span className='published-date'>{' '}&#40;Updated on {result.updatedDate}&#41;</span>)}
                    <div className='result-title'>
                      <a href={result.url} className='result-title-link'>
                        <h2 className='result-title-label'>
                          {result.title} 
                          {/* ToDo: This need to be dynamic */}
                          <span className='filetype-label'>PDF</span>
                        </h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>{result.description}</p>
                      <div className='result-url-text'>{truncateUrl(result.url, URL_LENGTH)}</div>
                    </div>
                  </Grid>
                </Grid>
                <Grid row className="row-mobile-divider"></Grid>
              </GridContainer>
            );
          })) : (
            <GridContainer className='result search-result-item'>
              <Grid row>
                <Grid tablet={{ col: true }}>
                  <h4>Sorry, no results found for &#39;{query}&#39;. Try entering fewer or more general search terms.</h4>
                </Grid>
              </Grid>
            </GridContainer>)}
        </div>
      </div>
      <Pagination 
        totalPages={totalPages}
        pathname={window.location.href}
        unboundedResults={unboundedResults}
      />
    </>
  );
};
