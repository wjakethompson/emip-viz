# Visualizing Different Levels of Compensation in Multidimensional Item Response Theory Models

Published version: https://doi.org/10.1111/emip.12177 (cover), https://doi.org/10.1111/emip.12179 (description)

This graphic shows the probability of providing a correct response to an item in a multidimensional item response theory (MIRT) model.
The colors represent the probability of a correct response, and the contours represent chunk of 10% probability (i.e., the space between the leftmost and second contours represents ability pairs with a 10-20% probability of answering correctly).

In this example, I use a 2-dimensional model to illustrate how the probabilities change depending on the parameterization of the model.
In the compensatory model, one dimension is able to compensate for the other, whereas in the noncompensatory model, an individual needs high ability on both dimensions to have a high probability of success.
The partially compensatory model is parameterized with an interaction term that allows one dimension to partially compensate for the other.

In the 1PL versions of these models, the b-parameters are set to 0, and the discriminations are fixed at 1, making this equivalent to the multidimensional Rasch model.
In the 2PL versions, the discrimination is set to 0.8 for the first dimension and 1.8 for the second dimension.
Accordingly, we can see the item get easier for individuals with low ability on dimension 1 and harder for individuals with low ability on dimension 2.
Finally, in the 3PL versions, the c-parameter is set to 0.2, and we can see the probability level off at 0.2, rather than reaching all the way down to 0 for individuals with low ability on both dimensions.
In all of the partially compensatory models, the discrimination for the interaction term is 0.3.

These plots show the 1PL, 2PL, and 3PL MIRT models are affected by how compensatory the model is parameterized to be.
Additionally, creating 2-dimensional representations of the 3-dimensional curves makes it easier to identify differences in between the partially compensatory and noncompensatory models that tend to look very similar when rendered in 3 dimensions.

![In the 1PL, 2PL, and 3PL MIRT models, the choice of compensatory parameterizations can greatly affect the probability of a correct response (b = 0 in all models; a1 = 0.8, a2 = 1.8 in 2PL and 3PL models, 0 in 1PL, a3 = 0.3 in all partially compensatory models; c = 0.2 in 3PL, 0 in 1PL and 2PL).](mirt-visualization.png)
