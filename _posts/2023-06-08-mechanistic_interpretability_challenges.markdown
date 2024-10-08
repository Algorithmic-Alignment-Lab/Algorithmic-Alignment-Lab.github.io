---
layout: default
title:  "Welcome to Jekyll!"
date:   2022-02-19 23:49:21 -0500
categories: jekyll update
---

{% include nav.html %}

# Takeaways from the Mechanistic Interpretability Challenges

## ...plus more challenges on the way 

Stephen Casper, <scasper@mit.edu>

Spoilers ahead

[Crossposted from the AI Alignment Forum](https://www.alignmentforum.org/posts/EjsA2M8p8ERyFHLLY/takeaways-from-the-mechanistic-interpretability-challenges)

## What happened?

The Mechanistic Interpretability Challenges ([post](https://www.alignmentforum.org/s/a6ne2ve5uturEEQK7/p/KSHqLzQscwJnv44T8) and [GitHub](https://github.com/thestephencasper/mechanistic_interpretability_challenge)) were two challenges I posed in February as part of the [Engineer's Interpretability Sequence](https://www.alignmentforum.org/s/a6ne2ve5uturEEQK7). The first challenge was to find the pseudocode for the labeling function used to train a small CNN MNIST classifier. It was [solved](https://www.alignmentforum.org/posts/sTe78dNJDGywu9Dz6/solving-the-mechanistic-interpretability-challenges-eis-vii) early last month. The second was to find the pseudocode for the labeling function used to train a one-layer transformer that classified pairs of numbers into two categories. It was [solved](https://www.alignmentforum.org/posts/k43v47eQjaj6fY7LE/solving-the-mechanistic-interpretability-challenges-eis-vii-1) (with some reservations) late last month. Instead of finding the labeling function, the researchers who solved it obtained a mechanistic explanation of how the model worked and argued that the labeling function's pseudocode would not be tractable to find from the model. 

## Thanks to Stefan, Marius, and Neel

Stefan Heimersheim and Marius Hobbhahn solved both challenges as a team. I and others have been impressed with their work. Meanwhile, Neel Nanda offered to contribute $500 to the prize pool for solving each challenge. Per the request of Stefan and Marius, a total of $1,500 has been donated by Neel and me to [AI Safety Support](https://www.aisafetysupport.org/).  

## Why These Challenges?

In the original post on the challenges, I argued that solving them would be one of the first clear examples of mechanistic interpretability being used to solve a problem that was not specifically selected to be solvable with mechanistic interpretability. 

Because it doesn't treat models as black boxes, mechanistic interpretability is one of the potential solutions we might have for diagnosing and debugging insidious alignment failures. For example, if a model has a trojan or plans to make a treacherous turn once it detects that it's in deployment, then these failures will be virtually undetectable from black-box access alone during training and development. 

Mechanistic interpretability has been a reasonably high-profile research area for the past 6 years or so in the AI safety community. And it is currently undergoing a renewed surge of interest. However, I have tried to be [critical](https://www.alignmentforum.org/s/a6ne2ve5uturEEQK7/p/wt7HXaCWzuKQipqz3) of the fact that much of the progress in mechanistic interpretability research has been on "[streetlight](https://en.wikipedia.org/wiki/Streetlight_effect) interpretability" projects often with cherrypicked models and tasks. As a result of this, there is a risk that, if mechanistic interpretability continues to be a field full of cherrypicked and toy work, it may fail to produce methods that keep up with state-of-the-art applications of AI. Certainly, progress in mechanistic interpretability has not kept up with progress in AI as a whole, and despite all of the interest from the AI safety community, it lacks any big wins or many real-world applications at all that produce competitive tools for engineers solving real-world problems. 

Hence the purpose of the mechanistic interpretability challenges: to provide challenges that aren't able to be cherrypicked by those undertaking them. The hope has been that these challenges and others like it could offer a useful way of testing how useful approaches to interpretability are. The goal is to measure how promising specific methods and mechanistic interpretability itself are for truly reverse engineering models performing tasks that don't happen to be under any particular streetlight. 

## The First Challenge: A Clear Win for MI

As is now public information, the MNIST CNN was trained on a labeling function that labeled images with small and large L1 distances to this image as a 1 while images with a medium L1 distance from it were labeled as a 0.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/EjsA2M8p8ERyFHLLY/e5mcqatr96k5f74xnj4f)

The [solution](https://www.alignmentforum.org/posts/sTe78dNJDGywu9Dz6/solving-the-mechanistic-interpretability-challenges-eis-vii) was thorough. The network developed a set of "detectors" and "anti-detectors" for this image in the penultimate layer. It labeled anything that was detected or anti-detected as a 1 while labeling everything else as a 0. This seems to be an example of an instance in which a neural network developed a coherent, easily-explainable solution to a problem (albeit a toy one) that lent itself to good mechanistic interpretations -- even without being specifically selected for this! Notably, the most compelling evidence from the solution involved a very clean application of causal scrubbing. I think this is a win for causal scrubbing as well. 

## The Second Challenge: Reasons for Both Optimism and Pessimism

In the second challenge, the labeling function and learned solution looked like this. 

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/EjsA2M8p8ERyFHLLY/tj7bhyaoesoaefdimbrc)

As is now public information, the labeling function was:

```
p = 113
def label_fn(x, y):
    z = 0
    if x ** 2 < np.sqrt(y) * 200:
        z += 3
    if y ** 2 < np.sqrt(x) * 600:
        z -= 2
    z += int(x ** 1.5) % 8 - 5
    if y < (p - x + 20) and z < -3:
        z += 5.5
    if z < 0:
        return 0
    else:
        return 1
```

The [solution](https://www.alignmentforum.org/posts/k43v47eQjaj6fY7LE/solving-the-mechanistic-interpretability-challenges-eis-vii-1) to it was equally well done as the first. It made a strong case that the model computed its label by doing almost all of the work with the embeddings alone. The MLP layers implemented a simple function, and the attention layers did very little. 

### What This Solution Did Not Do

First, I would have liked to see an explanation of why the transformer only seems to make mistakes near the parts of the domain where there are curved boundaries between regimes. Meanwhile, the network did a great job of learning the (transformed) periodic part of the solution that led to irregularly-spaced horizontal bars. Understanding why this is the case seems interesting but remains unsolved.

**Second, this solution did not solve the mechanistic interpretability challenge as it was posed.** It did not find pseudocode for the labeling function, but instead made a strong case that it would not be tractable to find this. In this case, the network seemed to learn to label points by interpolating from nearby ones rather than developing an interesting, coherent internal algorithm. As a result, this seems to be a counterexample to some of the reasons that people are optimistic about mechanistic interpretability. 

I think that streetlighting and cherrypicking in mechanistic interpretability may lead to a harmful notion that deep down, under the hood, neural networks are doing program induction. **To the extent that neural networks do interpolation instead of program induction, then we should not be looking for the type of thing that the** [**progress measures**](https://arxiv.org/abs/2301.05217) **paper showed.** This also seems to dampen optimism about [microscope AI](https://www.alignmentforum.org/posts/YQALrtMkeqemAF5GX/another-list-of-theories-of-impact-for-interpretability#:~:text=doing%20something%20dangerous-,Microscope%20AI,-Instead%20of%20building) -- even if one has an excellent mechanistic understanding of a model, it may not transfer to useful domain knowledge. In the wild, there is a lot of empirical (e.g. difficulties of mechanistic interpretability) and theoretical (e.g. [NTK](https://arxiv.org/abs/1806.07572) theory) support for the idea that neural networks do not do program induction. Accordingly, I would [argue](https://www.alignmentforum.org/s/a6ne2ve5uturEEQK7/p/7TFJAvjYfMKxKQ4XS) that **we should expect very limited amounts of progress and little scalability from attempts to develop thorough prosaic, understandings of non-toy models performing non-cherrypicked tasks.**

Nonetheless, I was excited to declare this challenge solved, just with an asterisk.

## Were the Challenges too Easy?

I don't think so. Stefan and Marius may have made them look easy, but they still spent quite a bit of effort on their solutions. Several others who attempted one or both of the challenges and contacted me found themselves stuck. However, I still did not expect that the challenges would be solved as well and as soon as they were. I thought they would stand for longer. 

But, of course, these two challenges were completely toy. Future challenges and benchmarks should not be. 

Two minor notes: (1) I regret providing the hint I did with the CNN challenge which showed the image that was used for the labeling function, but I am confident that Stefan and Marius would have solved it without the hint anyway. (2) As the person behind the challenges, I could have refused to consider the transformer challenge solved without pseudocode for the labeling function -- demonstrating that this is hard to do was one of the main points of the challenge in the first place. But I do not think this would have been the right thing to do, and I fully believe that the solution was illuminating and thorough enough to deserve a win. I do not think there is very much reasonable room for improvement.

## These are Just One of the Ways to Evaluate Interpretability Work

In the past, I have expressed a lot of optimism for objective ways to evaluate approaches to interpreting models -- something that is currently lacking in the space. There are [three ways](https://www.alignmentforum.org/s/a6ne2ve5uturEEQK7/p/gwG9uqw255gafjYN4#If_we_want_interpretability_tools_to_help_us_do_meaningful__engineering_relevant_things_with_networks__we_should_establish_benchmarks_grounded_in_useful_tasks_to_evaluate_them_for_these_capabilities__) that interpretability tools can be evaluated. I wrote about them in [EIS XI](https://www.alignmentforum.org/s/a6ne2ve5uturEEQK7/p/L5Rua9aTndviy8dvc#Benchmarking):

1. **Making novel predictions about how the system will handle interesting inputs.** This is what we worked on in [Casper et al. (2023)](https://arxiv.org/abs/2302.10894). Approaches to benchmarking in this category will involve designing adversaries and detecting trojans. 

2. **Controlling what a system does by guiding manipulations to its parameters.** Benchmarks based on this principle should involve implanting and/or removing trojans or changing other properties of interest. [Wu et al. (2022)](https://backdoorbench.github.io/) provide benchmarks involving tasks with trojans that are somewhat related to this.

3. **Abandoning a system that does a nontrivial task and replacing it with a simpler reverse-engineered alternative.** Benchmarks for this might involve using interpretability tools to reconstruct the function that was used to design or supervise a network. This is the kind of thing that this challenge and [Lindner et al. (2023)](https://arxiv.org/abs/2301.05062) focus on.

Moving forward, various benchmarks and competitions based on these three basic approaches might be very stimulating and healthy for the mechanistic interpretability community. Some of this seems to be catching on. For example, there has been a lot of interest in using [Tracr](https://arxiv.org/abs/2301.05062) to build networks that have a known algorithmic function. I hope that we see continued interest in this and more. 

Benchmarks offer feedback, concretize goals, and can spur coordinated research efforts. Benchmarks are not the real world, and it is important not to overfit to them, but they [seem](https://www.alignmentforum.org/posts/AtfQFj8umeyBBkkxa/a-bird-s-eye-view-of-the-ml-field-pragmatic-ai-safety-2) to have an unparalleled ability to lead to engineering progress in a field. Benchmarks like CIFAR, ImageNet, GLUE, SuperGLUE, Big Bench, and others have led to so much progress in vision and language. So I hope that not too long from now, there are some widely-applicable benchmarks (or at least *types* of benchmarking tasks) used for interpretability, diagnostic, and debugging tools.

## More (Non-Toy) Challenges Coming Soon

Soon, my labmates, coauthors, and I will roll out a new competition for interpretability tools. It will be based on [this paper](https://arxiv.org/abs/2302.10894) in which we evaluate interpretability tools based on their ability to help humans identify trojans in ImageNet models. There will be two challenges.

One will be to beat all of the methods we benchmarked in the paper. The challenge will be to produce a set of visualizations that are meant to help humans identify trojan triggers for the 12 trojans that we work with in the paper. Given a submission consisting of images and code to reproduce them, we will send them to knowledge workers just like we did with other methods in the paper. If your images beat the best result from the paper (which was a success rate of 0.49 on our 8-way multiple choice questions), you'll beat the challenge.

The second challenge will be to, by any means necessary (mechanistic interpretability or not), identify the triggers for four secret trojans using only the ImageNet network with the trojans and the target class. 

**For updates on this challenge, please** [**sign up here**](https://docs.google.com/forms/d/e/1FAIpQLSfQiHha4eSJZI6ShawtA-UC4eptGqVZg_DdwfGStEBvu_8vrg/viewform?usp=sf_link) **to receive a one-time email announcement later this year.**
