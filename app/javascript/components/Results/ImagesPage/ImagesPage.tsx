import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { clickTracking } from '../../../utils';

type Image = {
  url: string;
  altText?: string;
  thumbnailUrl?: string;
}[];

interface ImagesPageProps {
  images?: Image;
  affiliate: string;
  query: string;
  vertical: string;
}

export const ImagesPage = ({ images=[], affiliate, query, vertical }: ImagesPageProps) => {  
  return (
    <GridContainer className='result search-result-item search-result-image-item'>
      <Grid row gap="md">
        {(images.map((image, index) => {
          return (
            <Grid key={index} mobileLg={{ col: 3 }} col={6} className='result-thumbnail margin-bottom-4'>
              <a
                href={image.url}
                onClick={() => clickTracking(affiliate, 'IMAG', query, index + 1, image.url, vertical)}
              >
                <img src={image.thumbnailUrl} className="result-image" alt={image.altText} />
              </a>
            </Grid>
          );
        }))}
      </Grid>
    </GridContainer>
  );
};
