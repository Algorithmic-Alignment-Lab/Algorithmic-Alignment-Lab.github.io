---
layout: default
title:  "Welcome to Jekyll!"
date:   2022-02-19 23:49:21 -0500
categories: jekyll update
---

{% include nav.html %}

# Seven Strategies for Tackling the Hard Part of the Alignment Problem

Stephen Casper, <scasper@mit.edu>


[Crossposted from the AI Alignment Forum](https://www.alignmentforum.org/posts/amBsmfFK4NFDtkHiT/seven-strategies-for-tackling-the-hard-part-of-the-alignment)

Thanks to Michael Ripa for feedback.

## TL;DR

-   There are two types of problems that AI systems can have: problems that we can observe during development and problems that we can't. The hardest part of the alignment problem involves problems we can't observe. 
-   I outline seven types of solutions for unobservable problems and taxonomize them based on whether they require that we know what failure looks like and how it happens mechanistically. 
    -   Solutions that require both knowing what failure looks like and how it happens
        -   Ambitious mechanistic interpretability
        -   Formal verification
    -   Solutions that require knowing what failure looks like
        -   Latent adversarial training
        -   Evals
    -   Solutions that require knowing how failure happens
        -   Mechanistic interpretability + heuristic model edits
    -   Solutions that require neither
        -   Anomaly detection
        -   Scoping models down
-   I argue that latent adversarial training, mechanistic interpretability + heuristic model edits, and scoping models down all may be highly important, tractable, and neglected and loft out a few ideas for new work. 

## Two ways that AI systems can fail

Consider a simple way of dividing AI failures into two groups. 

1.  **Observable failures:** Failures that we can encounter in training and development. These include failures on the train set, test set, some types of adversaries, or anything else that we might think to test our AI system on. These can be very bad, but they are problems that we can get feedback on -- we can spot them and then work to fix them. 
2.  **Unobservable failures:** Failures that we will *not* encounter in training and development. These failures are somewhat scarier and harder to address because we will not have feedback to help us solve them. These can include trojans, some adversarial examples, misgeneralization, and deceptive alignment. 

Because one cannot get feedback on them, unobservable failures are the harder part of AI alignment, and this is why the AI safety community is especially interested in them. It is important not to ignore the importance and difficulty of fixing observable problems, and there might exist a very valid critique of the AI safety community's (over)emphasis on unobservable ones. However, this post will focus on unobservable failures. 

What are the ways that we can try to tackle unobservable failures? One good way may be to use models and data that are designed to avoid some of these problems in the first place (e.g. use better training data), but this will be outside the scope of this post. Instead, I will focus on ways to remove problems *given* a model and training set.  

## A taxonomy of solutions

Consider two things that might make the process of addressing an unobservable problem in a model very difficult. 

1.  **Knowing what failure looks like.** Can we recognize the bad behaviors when we see them? Lots of the time in ML, bad behavior is thought of as something that can be detected from a single output/action. But in reality, badness may be a property of a trajectory and may not be recognizable in simple ways. 
2.  **Knowing how the failure happens.** Can we figure out the internal mechanisms behind failures? This a difficult challenge because neural networks are hard to understand in terms of faithful mechanistic interpretations. 

Now consider which approaches to tackling unobservable failures depend on solving each of these two challenges.

### (Hard) Approaches that require both knowing what failure looks like and how it happens:

-   **Ambitious mechanistic interpretability:** This refers to anything that involves using mechanistic interpretability to actually figure out how the model will do something bad. Once this is done, then the model that will do bad things can be deleted or modified. 
-   **Formal verification:** This refers to anything involving a proven bound on the probability of failures conditional on a particular set of specifications for using the model. In general, this is hard -- the deep learning field struggles to prove practically-useful bounds for model failures. 

### (Medium) Approaches that require knowing what failure looks like.

-   **Latent adversarial training:** [Latent adversarial training](https://www.alignmentforum.org/posts/atBQ3NHyqnBadrsGP/latent-adversarial-training) is an example of [relaxed adversarial training](https://www.alignmentforum.org/posts/9Dy5YRaoCxH9zuJqa/relaxed-adversarial-training-for-inner-alignment) in which the model is trained under adversarial perturbations to its internal activations (instead of its inputs). Even if the inputs that trigger model failures are rare, there will likely be a substantial amount of neural circuitry dedicated to many unobservable failures (e.g. trojans, deceptive alignment). As long as bad behavior can be recognized when it happens, this relaxation of the adversarial training process could help to train that bad circuitry out of models without knowing what triggers it or how the network processes the bad response. 
-   **Evals:** Black-box evals aren't solutions to unobservable failures in theory. But evals can be informed by *white-box* analysis, and in reality, we also may be able to get a long way with good methodology and honeypotting.

### (Medium) Approaches that require knowing how failure happens.

-   **Mechanistic interpretability + heuristic model edits:** This refers to identifying model mechanisms or knowledge that seem likely to be involved in failures and then editing the model to address them. 

### (Easy) Approaches that don't require either.

-   **Mechanistic anomaly detection:** this could allow us to find and flag examples that could be risky on the basis that the model internally handles them differently than typical inputs. 
-   **Scoping models down:** If we are worried that we might accidentally be giving our models bad capabilities or intentions that will manifest off the train distribution, we may be able to get rid of many of these liabilities with tools to impair the model's ability to do anything very coherent off distribution. For example, the model could be compressed or distilled on its own outputs so that it retains in-distribution performance and (not-so-catastrophically) forgets possibly-dangerous behaviors off distribution. 

## What does this framework suggest?

First, I have simply found this taxonomy useful for how I think about the hard part of alignment and the set of strategies we have for addressing it.

Next, I would not be surprised if we lived in a world in which the hard strategies -- ambitious mechanistic interpretability and formal verification -- just never pan out. I have [written](https://www.alignmentforum.org/s/a6ne2ve5uturEEQK7) in the past about how AI interpretability might be unproductive in some ways. This framing might help underscore some of these points. 

In particular, I think this taxonomy helps to suggest that latent adversarial training, mechanistic interpretability + heuristic model edits, and scoping models down might be important, tractable, and neglected strategies. None seem to get a lot of current attention among AI safety researchers in deep learning, but all three seem to be tractable and have a high upside. (I'd also group evals and mechanistic anomaly detection in with these, but they seem slightly less neglected at the moment.)

### Latent adversarial training

I think that it is possible for latent adversarial training to do most of what the mechanistic interpretability field is trying to achieve with less invested effort. The useful thing about latent adversarial training is that if you can solve the oversight problem, training under the *right* latent perturbations will, at least in theory, make the model robust to unobservable failures. Both of those things are much easier said than done. But ambitious mechanistic interpretability requires both of these plus a precise understanding mechanisms responsible for bad behavior plus using that understanding to address them somehow. It just seems strictly harder. 

Right now, I am working with some others at MIT on latent adversarial training in deep learning. We are hoping to use it to improve robustness for high-stakes reliability and to help remove/resist trojan implantation. Some work already exists that involves adversarial perturbations to model latents (e.g. [this paper](https://arxiv.org/abs/2104.01575)), but to our knowledge, we are working to be the first to use it for controlling OOD liabilities in deep learning. I think that much more work could be done in the future as well.

### Mechanistic Interpretability + Heuristic Model Edits

Getting rid of knowledge in models that might be risky could be very useful for safety. It might be nice to be able to take a language model and erase its knowledge entirely on some risky domain. For instance, maybe future versions of ChatGPT should have all of their knowledge of biotech erased so that they cannot effectively help to make a bioweapon. How might we go about this?

Recently, there has been [a](https://arxiv.org/abs/2202.05262) [lot](https://arxiv.org/abs/2210.07229) [of](https://arxiv.org/pdf/2301.04213.pdf) [interest](https://scholar.google.com/citations?view_op=view_citation&hl=en&user=dnZ8udEAAAAJ&sortby=pubdate&citation_for_view=dnZ8udEAAAAJ:sSrBHYA8nusC) in editing factual associations in models. Prior works have modeled factual knowledge as labeled arrows between concepts, e.g. eiffel tower --> located in --> Paris. Maybe using some strategy based on these tools would work well, and we should find out. But not all types of knowledge seem most easily described as sets of simple, directed relations between entities (e.g. knowledge within a broad domain like biotech). So it may be useful to work on methods to completely erase a model's knowledge in large domains. Methods like this might be great to add to the alignment toolbox. 

### Scoping Models Down

This may be an underrated approach to alignment -- just making the AI more narrow. Right now, state-of-the-art AI systems are developed under a pretrain-then-finetune paradigm. But it might be valuable from a safety perspective to move to a pretrain-then-finetune-then-scope-down one. 

One useful approach for scoping models down could involve using network compression. If a model does something bad off distribution (like executing a precise plot to betray you), the forward passes through it are going to be mechanistically different in some way compared to the passes that are observed during development. Using a mechanistic compression technique to get rid of neural circuitry which is not needed for in-distribution performance might disrupt the ability of the network to make the same computations off distribution. This could incidentally remove much of the circuitry involved in some types of OOD failures without ever needing to identify those failures in the first place. 

Network pruning has been [observed](https://arxiv.org/abs/2103.03014) to harm OOD performance before, and from a safety standpoint, this may be a feature -- not a bug. Right now could be a good time to work on scoping models down for alignment via compression because of recent interest in causal compression methods (like [causal scrubbing](https://www.alignmentforum.org/posts/JvZhhzycHu2Yd57RN/causal-scrubbing-a-method-for-rigorously-testing) or [ACDC](https://arxiv.org/abs/2304.14997)). These methods are being used for mechanistic anomaly detection and automating "interpretations" of networks, but we might be able to get a long way with just the compressed networks themselves.

Another approach for scoping models down could be inspired by the [continual learning](https://arxiv.org/abs/1909.08383) literature which aims to make models better at learning new tasks without forgetting old ones. If we want to scope a model down, the whole point will be to make it forget previously learned information that isn't related to the in-distribution data we supervisedly finetune it on. In this case, [continued training](https://arxiv.org/abs/2306.00427), [several](https://arxiv.org/abs/2211.12044?fbclid=IwAR1Qupu_GUsQDmdK2o7YAMQWrkUv38n5Kxff9w_9FyIQpK1iU6dIGLb9UhE) [approaches](https://arxiv.org/abs/2306.00427) [using](https://arxiv.org/abs/2303.10594?fbclid=IwAR0_XiZiSSM5BElLcCahEczDbody9ndLZLW2ELDOvytqQSmO0F6ifN39zPQ) [distillation](https://arxiv.org/abs/2101.05930?fbclid=IwAR1IsetxvmzV6qze9411LK08CDt9mxC47_K9_eAezjVXnDq5N9xTJ2lmFkY), [excitation dropout](https://arxiv.org/abs/1805.09092), and [unlearning followed by re-learning](https://arxiv.org/abs/2212.04687?fbclid=IwAR0dol7NBf8_Kej9eLc19lkMr4CoIlYXfp3h2X11GE6pafgyW5SPKENGC68) seem promising. However, there seems to be more work needed to develop methods and benchmark them. I think that one promising idea could also be to test how useful taking [existing continual learning techniques](https://arxiv.org/abs/1909.08383) and doing the opposite could encourage the type of plasticity/forgetting that would help to scope models down. Trojan removal seems like a promising testbed for this type of work. 

## Paying the Alignment Tax

When I have talked to people about some of these approaches, they sometimes bring up the concern that this might make the models bad and less competitive. But that's kind of the point. AI safety is much more about a lack of certain capabilities than having certain capabilities. Any aligned model is going to be worse in some way than the easier, misaligned alternative. That's just the alignment tax. For example, adversarial training and content filters make models worse too, and we tolerate that ChatGPT is often stubbornly unhelpful. It's just the price to pay.

Let me know if you are interested in working on any of these ideas :)