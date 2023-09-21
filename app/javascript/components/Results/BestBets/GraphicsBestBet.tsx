import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

interface GraphicsBestBetProps {
  title: string;
  titleUrl?: string;
  imageUrl?: string;
  imageAltText?: string;
  links?: {
    title: string;
    url: string;
  }[];
}

export const GraphicsBestBet = ({ title, titleUrl, imageUrl, imageAltText, links }: GraphicsBestBetProps) => {
  return (
    <GridContainer className='result search-result-item graphics-best-bets featured-collection'>
      <Grid row gap="md">
        {imageUrl && (
          <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
            <img src={imageUrl} alt={imageAltText && imageAltText} className="result-image"/>
          </Grid>
        )}
        <Grid col={true} className='result-meta-data'>
          <div className='graphics-best-bets-title'>
            {titleUrl ? (
              <a href={titleUrl}>{parse(title)}</a>) : (parse(title)
            )}
          </div>
          {links && links.length > 0 && (
            <Grid row gap="md">
              {links.map((link, index) => {
                return (
                  <Grid key={index} mobileLg={{ col: (index as number) % 2 === 0 ? 7 : 5 }} className='graphics-best-bets-link-wrapper'>
                    <a href={link.url}>{parse(link.title)}</a>
                  </Grid>
                );
              })}
            </Grid>
          )}
        </Grid>
      </Grid>
    </GridContainer>
  );
};
